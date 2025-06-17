
UPDATE PV_DocumentTypes
SET workflowId = 1
WHERE documentTypeId IN (1, 2);

INSERT INTO PV_workflowsType(name)
VALUES( 'Revisión de propuesta');

INSERT INTO PV_workflows (name,description,endpoint,workflowTypeId,params)
VALUES ('Validar Propuesta','Workflow para validación automática y manual de propuestas','/api/workflows/validar-propuesta',3,  N'{"ai":{"enabled":true,"threshold":0.8},"review":{"required":true,"roleId":2,"days":7},"autoApprove":false}'
);