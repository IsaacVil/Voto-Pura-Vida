--Llenado de mediaType, necesarios para el SP_CrearActualizarPropuesta

INSERT INTO dbo.PV_mediaTypes (name, playerimpl) 
VALUES 
('PDF', 'PDFReader'),
('MP3', 'AudioPlayer'),
('MP4', 'VideoPlayer'),
('JPEG', 'ImageViewer');
