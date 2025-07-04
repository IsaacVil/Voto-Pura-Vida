CREATE PROCEDURE [dbo].[SP_Dashboard]
    @Email VARCHAR(120)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT;

    SELECT @UserId = u.userid
    FROM PV_Users u
    INNER JOIN PV_UserStatus us ON u.userStatusId = us.userStatusId
    WHERE u.email = @Email AND us.active = 1 AND us.verified = 1;

    IF @UserId IS NULL
    BEGIN
        SELECT 'ERROR: Usuario no encontrado o credenciales incorrectas.' AS Error;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM PV_UserRoles ur
        WHERE ur.userid = @UserId AND (ur.roleid = 2 OR ur.roleid = 3) AND ur.enabled = 1 AND ur.deleted = 0
    )
    BEGIN
        SELECT 'ERROR: El usuario no tiene los permisos necesarios.' AS Error;
        RETURN;
    END

    
    ;WITH VotosPorOpcionSegmento AS (
        SELECT
            vm.votingconfigid,
            vm.optionid,
            vm.segmentid,
            SUM(vm.voteCounter) AS Votos
        FROM PV_VotingMetrics vm
        WHERE vm.isactive = 1
        GROUP BY vm.votingconfigid, vm.optionid, vm.segmentid
    ),
    TopVotingDetails AS (
        SELECT
            vc.votingconfigid,
            p.proposalid,
            p.title AS Propuesta,
            qt.name AS TipoPropuesta,
            q.question AS Pregunta,
            vo.optionid,
            vo.optiontext AS Opcion,
            ISNULL(vps.Votos, 0) AS Votos,
            ISNULL(ps.name, 'General') AS Segmento,
            ISNULL(vps.segmentid, 0) AS SegmentId,
            vc.startdate
        FROM PV_VotingConfigurations vc
        INNER JOIN PV_Proposals p ON vc.proposalid = p.proposalid
        INNER JOIN PV_ProposalTypes qt ON p.proposaltypeid = qt.proposaltypeid
        INNER JOIN PV_VotingOptions vo ON vo.votingconfigid = vc.votingconfigid
        INNER JOIN PV_VotingQuestions q ON vo.questionId = q.questionId
        LEFT JOIN VotosPorOpcionSegmento vps ON vps.votingconfigid = vc.votingconfigid AND vps.optionid = vo.optionid AND vps.segmentid IS NOT NULL
        LEFT JOIN PV_PopulationSegments ps ON vps.segmentid = ps.segmentid
        WHERE vc.startdate IS NOT NULL
        GROUP BY vc.votingconfigid, p.proposalid, p.title, qt.name, q.question, vo.optionid, vo.optiontext, vps.Votos, ps.name, vps.segmentid, vc.startdate
    ),
    TopVotings AS (
        SELECT TOP 5 proposalid, MAX(startdate) AS startdate
        FROM TopVotingDetails
        GROUP BY proposalid
        ORDER BY MAX(startdate) DESC
    )

    SELECT
        d.proposalid,
        d.Propuesta,
        d.TipoPropuesta,
        d.Pregunta,
        d.Opcion,
        d.Votos,
        d.Segmento,
        d.SegmentId,
        d.startdate,
        ISNULL(p.budget, 0) AS MontoSolicitado,
        ISNULL(inv.totalInvertido, 0) AS MontoInvertido,
        ISNULL(ejec.totalEjecutado, 0) AS MontoEjecutado
    FROM TopVotingDetails d
    INNER JOIN TopVotings tv ON d.proposalid = tv.proposalid
    LEFT JOIN PV_Proposals p ON d.proposalid = p.proposalid
    LEFT JOIN (
        SELECT proposalid, SUM(amount) AS totalInvertido
        FROM PV_Investments
        GROUP BY proposalid
    ) inv ON inv.proposalid = p.proposalid
    LEFT JOIN (
        SELECT ia.proposalid, SUM(is2.amount) AS totalEjecutado
        FROM PV_InvestmentAgreements ia
        INNER JOIN PV_investmentSteps is2 ON ia.agreementId = is2.investmentAgreementId
        GROUP BY ia.proposalid
    ) ejec ON ejec.proposalid = p.proposalid
    ORDER BY d.startdate DESC;
END;


