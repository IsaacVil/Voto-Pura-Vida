#Libreria necesaria pip install sqlalchemy pyodbc
import hashlib
import socket
from sqlalchemy import create_engine, Column, Integer, String, DateTime, BigInteger, LargeBinary, Text, ForeignKey, desc
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime


# Conexión a SQL Server
engine = create_engine(
    'mssql+pyodbc://usuario_conexion:TuContraseñaSegura123@localhost/VotoPuraVida?driver=ODBC+Driver+17+for+SQL+Server'
)

Base = declarative_base()
Session = sessionmaker(bind=engine)
session = Session()

#-Mapeo de las tablas como clases-------------------------------------------------------------
class PV_Users(Base):
    __tablename__ = 'PV_Users'

    userid = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(120), nullable=False)
    firstname = Column(String(50), nullable=False)
    lastname = Column(String(50), nullable=False)
    birthdate = Column(DateTime, nullable=False)
    createdAt = Column(DateTime, nullable=False)
    genderId = Column(Integer, nullable=False)
    lastupdate = Column(DateTime, nullable=False)
    dni = Column(BigInteger, nullable=False)
    userStatusId = Column(Integer, nullable=True)

class PV_UserStatus(Base):
    __tablename__ = 'PV_UserStatus'
    userStatusId = Column(Integer, primary_key=True, autoincrement=True)
    active = Column(Integer)
    verified = Column(Integer)

class PV_Genders(Base):
    __tablename__ = 'PV_Genders'
    genderId = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), nullable=False)


class PV_MFA(Base):
    __tablename__ = 'PV_MFA'
    MFAid = Column(Integer, primary_key=True, autoincrement=True)
    MFAmethodid = Column(Integer, nullable=False)
    MFA_secret = Column(LargeBinary(256), nullable=False)
    createdAt = Column(DateTime, nullable=False)
    enabled = Column(Integer, nullable=False)
    organizationid = Column(Integer, nullable=True)
    userid = Column(Integer, nullable=True)  # Relación directa con usuario

class PV_Proposals(Base):
    __tablename__ = 'PV_Proposals'
    proposalid = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    proposalcontent = Column(Text, nullable=False)
    budget = Column(BigInteger, nullable=True)
    createdby = Column(Integer, nullable=True)
    createdon = Column(DateTime, nullable=False)
    lastmodified = Column(DateTime, nullable=False)
    proposaltypeid = Column(Integer, nullable=False)
    statusid = Column(Integer, nullable=False)
    organizationid = Column(Integer, nullable=True)
    checksum = Column(LargeBinary(256), nullable=False)
    version = Column(Integer, nullable=False)

class PV_VotingConfigurations(Base):
    __tablename__ = 'PV_VotingConfigurations'
    votingconfigid = Column(Integer, primary_key=True, autoincrement=True)
    proposalid = Column(Integer, nullable=False)
    startdate = Column(DateTime, nullable=False)
    enddate = Column(DateTime, nullable=False)
    votingtypeId = Column(Integer, nullable=False)
    allowweightedvotes = Column(Integer, nullable=False)
    requiresallvoters = Column(Integer, nullable=False)
    notificationmethodid = Column(Integer, nullable=True)
    userid = Column(Integer, nullable=False)
    configureddate = Column(DateTime, nullable=False)
    statusid = Column(Integer, nullable=False)
    publisheddate = Column(DateTime, nullable=True)
    finalizeddate = Column(DateTime, nullable=True)
    publicVoting = Column(Integer, nullable=True)
    checksum = Column(LargeBinary(250), nullable=False)

class PV_Votes(Base):
    __tablename__ = 'PV_Votes'
    voteid = Column(Integer, primary_key=True, autoincrement=True)
    votingconfigid = Column(Integer, nullable=False)
    votercommitment = Column(LargeBinary(256), nullable=False)
    encryptedvote = Column(LargeBinary(512), nullable=False)
    votehash = Column(LargeBinary(256), nullable=False)
    nullifierhash = Column(LargeBinary(256), nullable=False)
    votedate = Column(DateTime, nullable=False)
    blockhash = Column(LargeBinary(256), nullable=False)
    merkleproof = Column(LargeBinary(1024), nullable=True)
    blockchainId = Column(Integer, nullable=True)
    checksum = Column(LargeBinary(250), nullable=False)
    userId = Column(Integer, nullable=False)
    publicResult = Column(String(50), nullable=True)

class PV_IdentityUserValidation(Base):
    __tablename__ = 'PV_IdentityUserValidation'
    userValidationId = Column(Integer, primary_key=True, autoincrement=True)
    userid = Column(Integer, nullable=True)
    validationid = Column(Integer, nullable=True)

class PV_IdentityValidations(Base):
    __tablename__ = 'PV_IdentityValidations'
    validationid = Column(Integer, primary_key=True, autoincrement=True)
    validationdate = Column(DateTime, nullable=False)
    validationtype = Column(String(30), nullable=False)
    validationresult = Column(String(20), nullable=False)
    aivalidationresult = Column(Text, nullable=True)
    validationhash = Column(LargeBinary(256), nullable=False)
    workflowId = Column(Integer, nullable=True)
    verified = Column(Integer, nullable=False)

class PV_Logs(Base):
    __tablename__ = 'PV_Logs'
    logid = Column(Integer, primary_key=True, autoincrement=True)
    description = Column(String(120), nullable=False)
    name = Column(String(50), nullable=False)
    posttime = Column(DateTime, nullable=False)
    computer = Column(String(45), nullable=False)
    trace = Column(String(200), nullable=False)
    referenceid1 = Column(BigInteger, nullable=True)
    referenceid2 = Column(BigInteger, nullable=True)
    checksum = Column(LargeBinary(250), nullable=False)
    logtypeid = Column(Integer, nullable=False)
    logsourceid = Column(Integer, nullable=False)
    logseverityid = Column(Integer, nullable=False)
    value1 = Column(String(250), nullable=True)
    value2 = Column(String(250), nullable=True)

class PV_LogTypes(Base):
    __tablename__ = 'PV_LogTypes'
    logtypeid = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(45), nullable=False)
    ref1description = Column(String(120), nullable=False)
    ref2description = Column(String(120), nullable=False)
    val1description = Column(String(120), nullable=False)
    val2description = Column(String(120), nullable=False)

class PV_LogSource(Base):
    __tablename__ = 'PV_LogSource'
    logsourceid = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(45), nullable=False)

class PV_LogSeverity(Base):
    __tablename__ = 'PV_LogSeverity'
    logseverityid = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(45), nullable=False)

#--------------------------------------------------------------------------------------------

#Codigo para crear los logs necesarios para la vista de votos
def get_or_create_logtype(name): #Si no existe crea el logtype, "LecturaVotoUsuario" que permite saber que info se guardara en ref1,rerf2,val1,val2.
    logtype = session.query(PV_LogTypes).filter_by(name=name).first()
    if not logtype:
        logtype = PV_LogTypes(
            name=name,
            ref1description="UserId",
            ref2description="ProposalId",
            val1description="Voto",
            val2description="Fecha"
        )
        session.add(logtype)
        session.commit()
    return logtype.logtypeid

def get_or_create_logsource(name): #Si no existe crea el logsource, "Pv_Votes" que permite saber de donde viene el log.
    logsource = session.query(PV_LogSource).filter_by(name=name).first()
    if not logsource:
        logsource = PV_LogSource(name=name)
        session.add(logsource)
        session.commit()
    return logsource.logsourceid

def get_or_create_logseverity(name): #Si no existe crea el logseverity, "info" que permite saber la gravedad del log.
    logseverity = session.query(PV_LogSeverity).filter_by(name=name).first()
    if not logseverity:
        logseverity = PV_LogSeverity(name=name)
        session.add(logseverity)
        session.commit()
    return logseverity.logseverityid

logtypeid = get_or_create_logtype("LecturaVotoUsuario")
logsourceid = get_or_create_logsource("Pv_Votes")
logseverityid = get_or_create_logseverity("Info")

#Usuario con verificacion (existe uservalidations con conexion validations.verified = 1)
#Usario con mfa (enable = 1)
#Usuario vivo (Status = 1 & active = 1)

usuarios_verificados = (
    session.query(PV_Users, PV_Genders)
    .join(PV_UserStatus, PV_Users.userStatusId == PV_UserStatus.userStatusId)
    .join(PV_Genders, PV_Users.genderId == PV_Genders.genderId)
    .join(PV_MFA, PV_Users.userid == PV_MFA.userid)
    .filter(
        (PV_UserStatus.verified == 1) &
        (PV_UserStatus.active == 1) &
        (PV_MFA.enabled == 1) &
        session.query(PV_IdentityUserValidation)
            .join(PV_IdentityValidations, PV_IdentityUserValidation.validationid == PV_IdentityValidations.validationid)
            .filter(
                (PV_IdentityUserValidation.userid == PV_Users.userid) &
                (PV_IdentityValidations.verified == 1)
            )
            .exists()
    )
    .all()
)

#Ultimas 5 Propuestas publicas de un Usuario

#Explicacion de porque solo devolvemos las propuestas publicas (debido al diseño de la base de datos):
#En este ORM no se hace descifrado pues no hace sentido a nivel de diseño, los votos se encriptan mediante las cryptokeys que solo pueden ser descencriptadas a su vez
#Por la pieza de informacion que se usa para cifrarlas (ya sea algo que sabe el usuario (password), tiene (algun objeto con pines) o es (una huella dactilar o retina)) que nos permite calcular
#un sha2_512 y nos da un numero grande la cual sirve de semilla para generar una llave con la que encriptar o desencriptar las cryptokeys
#Entonces solo el usuario mismo puede pedir un informe asi, por el nivel tan alto de seguridad y privacidad que manejamos
#Solo podemos entregar la informacion publica (publicResult != null), eso fue lo que devolvimos.

#Se trae los ultimos 5 votos de un usuario que tenga publicos, Se hace un join entre proposal, voteconfig y votes.
#Devolverla toda esa informacion para imprimir en el query.

def ultimas_propuestas_votadas_por_usuario(userid):
    resultados = (
        session.query(PV_Proposals, PV_Votes.publicResult, PV_Votes.votedate)
        .join(PV_VotingConfigurations, PV_Proposals.proposalid == PV_VotingConfigurations.proposalid)
        .join(PV_Votes, PV_VotingConfigurations.votingconfigid == PV_Votes.votingconfigid)
        .filter(PV_Votes.userId == userid)
        .filter(PV_Votes.publicResult != None)
        .order_by(desc(PV_Votes.votedate))
        .limit(5)
        .all()
    )
    return resultados



#Funcion para poder leer los logs que dejara la funcion de revisar 5 propuestas
def leer_logs_votos_usuario_propuesta(userid, proposalid):
    logs = (
        session.query(PV_Logs)
        .filter(
            PV_Logs.name == "LecturaVotoUsuario",
            PV_Logs.referenceid1 == userid,
            PV_Logs.referenceid2 == proposalid
        )
        .order_by(PV_Logs.posttime.desc())
        .all()
    )
    if not logs:
        print(f"No hay logs para el usuario {userid} y la propuesta {proposalid}.")
        return

    print(f"Logs de lectura de votos para usuario {userid} y propuesta {proposalid}:")
    for log in logs:
        print(f"Fecha: {log.posttime}, Descripción: {log.description}")
        print(f"Trace: {log.trace}")
        print(f"Computer: {log.computer}")
        print(f"Checksum (hex): {log.checksum.hex()}")
        print("-" * 120)




#Caso de Uso:
useridunitario = 1
usuario_verificado = False
for usuario, genero in usuarios_verificados: #Userid == Useridunitario, para verificar que el user esta verificado (en la lista de verificados)
    if usuario.userid == useridunitario:
        usuario_verificado = True
        break

if (usuario_verificado):
    propuestas = ultimas_propuestas_votadas_por_usuario(useridunitario)
    if len(propuestas) != 0:
        print("                                                                                                                                                      ")
        print(f"Top 5 Propuestas del Usuario Verificado: {useridunitario}-----------------------------------------------------------------------------------------------------------")
        for propuesta, voto, fecha_voto in propuestas:
            print(f"ID de la propuesta: {propuesta.proposalid}, Título: {propuesta.title}, Fecha creación: {propuesta.createdon}")
            print(f"Voto del usuario: {voto}")
            print(f"Fecha del voto: {fecha_voto}")
            
            # Crear el string para el checksum con todos los datos relevantes del log
            checksum_str = (
                f"{useridunitario}|"
                f"{propuesta.proposalid}|"
                f"{voto}|"
                f"{propuesta.createdon}|"
                f"LecturaVotoUsuario|"
                f"{socket.gethostname()}|"
                f"{datetime.now()}|"
                f"{voto}|"
                f"{fecha_voto}"
            )
            checksum_bytes = hashlib.sha512(checksum_str.encode('utf-8')).digest()

            # Guardar log por cada voto mostrado
            log = PV_Logs(
                description=f"Lectura voto usuario {useridunitario} propuesta {propuesta.proposalid}",
                name="LecturaVotoUsuario",
                posttime=datetime.now(),
                computer=socket.gethostname(),
                trace=f"Voto: {voto}, Fecha del Voto: {fecha_voto},Fecha de creacion de la Propuesta: {propuesta.createdon}",
                referenceid1=useridunitario,
                referenceid2=propuesta.proposalid,
                checksum=checksum_bytes,
                logtypeid=logtypeid,
                logsourceid=logsourceid,
                logseverityid=logseverityid,
                value1=str(voto),  # Aquí se guarda el voto
                value2=str(fecha_voto)  # Aquí se guarda la fecha del voto
            )
            session.add(log)
        session.commit()
        print("------------------------------------------------------------------------------------------------------------------------------------------------------")
        print("                                                                                                                                                      ") 
    else:
        print("                                                                                                                                                      ") 
        print(f"Este Usuario no tiene votos validos para la lectura")
        print("                                                                                                                                                      ") 
else:
    print("                                                                                                                                                      ") 
    print(f"El usuario {useridunitario} no cumple las condiciones, puede que no tenga MFA, no este habilitado, este inactivo o sin verificar")
    print("                                                                                                                                                      ") 

##Crypto Keys Users: Se encriptan los privatekey y publickey mediante un password que sepa el usuario (que no guardemos) o en otro caso se puede generar con algo que el posea similar a los pincitos de los bancos para hacer un simpe.
##Hasta con la huella dactilar. Cuando el usuario escriba el password se calcula un sha2_512 y nos da un numero grande que es la semilla para generar una llave y con esa llave encriptamos las cryptokeys y desencriptamos
##(por que produce ese hash (semilla) de la que estamos hablando).


print("                                                                                                                                                                          ")
print("                                                                                                                                                                          ")
print("En este ORM no se hace descifrado pues no hace sentido a nivel de diseño, los votos se encriptan mediante las cryptokeys que solo pueden ser descencriptadas a su vez")
print("Por la pieza de informacion que se usa para cifrarlas (ya sea algo que sabe el usuario (password), tiene(algun objeto con pines) o es(una huella dactilar o retina)) que nos permite calcular")
print("un sha2_512 y nos da un numero grande la cual sirve de semilla para generar una llave con la que encriptar o desencriptar las cryptokeys")
print("Entonces solo el usuario mismo puede pedir un informe asi, por el nivel tan alto de seguridad y privacidad que manejamos")
print("Solo podemos entregar la informacion publica (publicResult != null), eso fue lo que devolvimos.")
print("                                                                                                                                                                          ")
print("                                                                                                                                                                          ")



# Codigo Extra para recorrer todos los votos publicos que tengan usuarios verificados
"""
for usuario, genero in usuarios_verificados:
    propuestas = ultimas_propuestas_votadas_por_usuario(usuario.userid)
    if len(propuestas) != 0:
        print("                                                                                                                                                      ")
        print(f"Top 5 Propuestas del Usuario Verificado: {usuario.userid}-----------------------------------------------------------------------------------------------------------")
        for propuesta, voto, fecha_voto in propuestas:
            print(f"ID de la propuesta: {propuesta.proposalid}, Título: {propuesta.title}, Fecha creación: {propuesta.createdon}")
            print(f"Voto del usuario: {voto}")
            print(f"Fecha del voto: {fecha_voto}")
            
            # Crear el string para el checksum con todos los datos relevantes del log
            checksum_str = (
                f"{usuario.userid}|"
                f"{propuesta.proposalid}|"
                f"{voto}|"
                f"{propuesta.createdon}|"
                f"LecturaVotoUsuario|"
                f"{socket.gethostname()}|"
                f"{datetime.now()}|"
                f"{voto}|"
                f"{fecha_voto}"
            )
            checksum_bytes = hashlib.sha512(checksum_str.encode('utf-8')).digest()

            # Guardar log por cada voto mostrado
            log = PV_Logs(
                description=f"Lectura voto usuario {usuario.userid} propuesta {propuesta.proposalid}",
                name="LecturaVotoUsuario",
                posttime=datetime.now(),
                computer=socket.gethostname(),
                trace=f"Voto: {voto}, Fecha del Voto: {fecha_voto},Fecha de creacion de la Propuesta: {propuesta.createdon}",
                referenceid1=usuario.userid,
                referenceid2=propuesta.proposalid,
                checksum=checksum_bytes,
                logtypeid=logtypeid, #VerVotos
                logsourceid=logsourceid, #Tabla Votes
                logseverityid=logseverityid, #Info
                value1=str(voto),  # Aquí se guarda el valor del voto
                value2=str(fecha_voto)  # Aquí se guarda la fecha en la que el usuario voto
            )
            session.add(log)
        session.commit()
        print("------------------------------------------------------------------------------------------------------------------------------------------------------")
        print("                                                                                                                                                      ") 
    else:
        print("                                                                                                                                                      ") 
        print(f"Este Usuario no tiene votos validos para la lectura")
        print("                                                                                                                                                      ") 
"""






















