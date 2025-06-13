insert into PV_workflowsType (name) values ('Encriptar documentos');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params)
VALUES (
  'Encriptar Mediafile',
  'Encripta el archivo físico de un mediafile usando la clave proporcionada',
  '/api/workflow/encrypt-mediafile',
  1,
  N'{
    "requiredFields": ["mediafileid", "cryptokeyid", "passwordhash"]
  }'
);
INSERT INTO PV_LogTypes(name, ref1description,  ref2description, val1description, val2description) 
values ('Run Workflow Encryp', 'mediafileid', 'cryptokeyid', 'Hora de inicio', 'mediafileid: ,cryptokeyid:');
INSERT INTO PV_LogTypes(name, ref1description,  ref2description, val1description, val2description) 
values ('End Workflow Encryp', 'mediafileid', 'cryptokeyid', 'Hora de finalizacion', 'Workflow Result');