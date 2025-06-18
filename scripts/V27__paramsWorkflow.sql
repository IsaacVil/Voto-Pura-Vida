
UPDATE PV_Workflows 
SET params = '{
    "documentId": "{{documentId}}",
    "documentType": "{{documentType}}",
    "mediaFileId": "{{mediaFileId}}",
    "proposalId": "{{proposalId}}",
    "timestamp": "{{timestamp}}",
}'
WHERE workflowId = 1;

UPDATE PV_Workflows 
SET params = '{
    "proposalId": "{{proposalId}}",
    "proposalTypeId": "{{proposalTypeId}}",
    "title": "{{title}}",
    "description": "{{description}}",
    "budget": "{{budget}}",
    "timestamp": "{{timestamp}}",
}'
WHERE workflowId = 4;