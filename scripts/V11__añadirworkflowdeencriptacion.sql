insert into PV_workflowsType (name) values ('Encriptar documentos');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params)
VALUES (
  'Encriptar Mediafile',
  'Encripta el archivo físico de un mediafile usando la clave proporcionada',
  '/api/workflow/encrypt-mediafile',
  1,
  N'{
    "requiredFields": ["mediafileid", "password"]
  }'
);