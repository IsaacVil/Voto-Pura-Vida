INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage)
VALUES 

(1, 'porcentaje_area_verde', 'min_value', '30', 'El parque debe contar con al menos un 30% de área verde'),  
(1, 'cantidad_bancas', 'min_value', '20', 'Debe haber al menos 20 bancas disponibles para los visitantes'),  
(1, 'tipo_iluminacion', 'allowed_values', 'LED,Solar', 'Solo se permiten sistema');