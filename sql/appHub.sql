-- Pulizia tabelle viste e tipo enumerativo creato
DROP VIEW IF EXISTS Media_sviluppatore;
DROP VIEW IF EXISTS Guadagni_APP;
DROP VIEW IF EXISTS Ricavi_Per_App;
DROP VIEW IF EXISTS App_Per_Piattaforma;
DROP VIEW IF EXISTS Dispositivi_Download;
DROP TABLE IF EXISTS Compatibilita;
DROP TABLE IF EXISTS Download;
DROP TABLE IF EXISTS Transazione;
DROP TABLE IF EXISTS Recensione;
DROP TABLE IF EXISTS Classificazione;
DROP TABLE IF EXISTS Dispositivo;
DROP TABLE IF EXISTS Applicazione;
DROP TABLE IF EXISTS Piattaforma;
DROP TABLE IF EXISTS Categoria;
DROP TABLE IF EXISTS Utente;
DROP TABLE IF EXISTS Sviluppatore;
DROP TABLE IF EXISTS Profilo_Fiscale;

DROP TYPE IF EXISTS tipoApp;

CREATE TABLE Profilo_Fiscale(
Partita_iva varchar(16) PRIMARY KEY,
Iban varchar(27) NOT NULL,
Nazione char(2) NOT NULL
);

CREATE TABLE Sviluppatore(
ID_Sviluppatore SERIAL PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,
Email VARCHAR(255) NOT NULL,
Sito_web Varchar(255) NOT NULL,
Fiscalita varchar(16) NOT NULL,
FOREIGN KEY (Fiscalita) REFERENCES Profilo_Fiscale(Partita_iva)
);
CREATE TYPE tipoApp AS ENUM ('Gratuita' , 'Premium');
CREATE TABLE Applicazione(
ID_App SERIAL PRIMARY KEY,
Sviluppatore INT NOT NULL,
Dimensione Decimal(8,2) NOT NULL,
Versione VARCHAR(20) NOT NULL,
Nome VARCHAR(100) NOT NULL,
Data_Rilascio DATE NOT NULL,
Num_Download INT NOT NULL,
Tipo tipoApp NOT NULL,
Giorni_Prova INT,
Prezzo DECIMAL(6,2),
Frequenza_Annunci INT,
Banner BOOLEAN,
FOREIGN KEY (Sviluppatore) REFERENCES Sviluppatore(ID_Sviluppatore),
CHECK(
(Tipo='Gratuita' 
AND Banner IS NOT NULL 
AND Frequenza_Annunci IS NOT NULL 
AND Giorni_Prova IS NULL 
AND Prezzo IS NULL)
OR
(Tipo='Premium' 
AND Giorni_Prova IS NOT NULL 
AND Prezzo IS NOT NULL 
AND Banner IS NULL 
AND Frequenza_Annunci IS NULL)
)
);

CREATE TABLE Categoria(
Nome Varchar(50) PRIMARY KEY
);

CREATE TABLE Classificazione(
Applicazione INT REFERENCES Applicazione(ID_App),
Categoria Varchar(50) REFERENCES Categoria(Nome),
PRIMARY KEY(Applicazione, Categoria)
);

CREATE TABLE Utente(
Nickname VARCHAR(50) PRIMARY KEY,
Email VARCHAR(255) UNIQUE NOT NULL, 
Data_Iscrizione DATE NOT NULL
);

CREATE TABLE Recensione(
Utente Varchar(50) REFERENCES Utente(Nickname),
Applicazione INT REFERENCES Applicazione(ID_App), 
Voto INT NOT NULL,
CHECK (Voto BETWEEN 1 AND 5),
Data DATE NOT NULL, 
Testo VARCHAR(256) NOT NULL,
PRIMARY KEY(Utente, Applicazione)
);

CREATE TABLE Transazione(
Codice VARCHAR(50),
Utente VARCHAR(50) NOT NULL, 
Applicazione INT NOT NULL, 
Importo DECIMAL(6,2) NOT NULL, 
Data_Pagamento TIMESTAMP NOT NULL,
Metodo_Pagamento VARCHAR(50) NOT NULL,
PRIMARY KEY(Codice),
FOREIGN KEY (Utente) REFERENCES Utente(Nickname),
FOREIGN KEY (Applicazione) REFERENCES Applicazione(ID_App)
);

CREATE TABLE Piattaforma(
Nome VARCHAR(50) PRIMARY KEY,
Produttore VARCHAR(100) NOT NULL
);

CREATE TABLE Dispositivo(
IMEI CHAR(15) PRIMARY KEY,
Utente Varchar(50) NOT NULL,
Marca VARCHAR(50) NOT NULL,
Modello VARCHAR(100) NOT NULL,
Piattaforma Varchar(50) NOT NULL,
Versione_Installata VARCHAR(20) NOT NULL,
FOREIGN KEY (Utente) REFERENCES Utente(Nickname),
FOREIGN KEY (Piattaforma) REFERENCES Piattaforma(Nome)
);


CREATE TABLE Download(
Utente Varchar(50) REFERENCES Utente(Nickname), 
Applicazione INT REFERENCES Applicazione(ID_App), 
Dispositivo CHAR(15) NOT NULL, 
Data_Ora TIMESTAMP NOT NULL,
PRIMARY KEY(Utente, Applicazione, Data_Ora),
FOREIGN KEY (Dispositivo) REFERENCES Dispositivo(IMEI)
);

CREATE TABLE Compatibilita(
Piattaforma VARCHAR(50) REFERENCES Piattaforma(Nome),
Applicazione INT REFERENCES Applicazione(ID_App),
Versione_Minima VARCHAR(20) NOT NULL,
PRIMARY KEY (Piattaforma, Applicazione)
);


-- ============================================================
-- 1. PROFILO FISCALE (15 record)
-- ============================================================
INSERT INTO Profilo_Fiscale (Partita_iva, Iban, Nazione) VALUES
('01234567890', 'IT60X0542811101000000123456', 'IT'),
('12345678901', 'IT28W0300203280794399388736', 'IT'),
('23456789012', 'IT40S0542811101000000234567', 'IT'),
('34567890123', 'IT52N0300203280123456789012', 'IT'),
('45678901234', 'IT64P0542811101000000345678', 'IT'),
('56789012345', 'IT76R0300203280987654321098', 'IT'),
('67890123456', 'IT88T0542811101000000456789', 'IT'),
('78901234567', 'IT10V0300203280567890123456', 'IT'),
('89012345678', 'IT22X0542811101000000567890', 'IT'),
('90123456789', 'IT34Z0300203280345678901234', 'IT'),
('11223344556', 'IT46B0542811101000000678901', 'IT'),
('22334455667', 'IT58D0300203280678901234567', 'IT'),
('33445566778', 'IT70F0542811101000000789012', 'IT'),
('44556677889', 'DE89370400440532013000',      'DE'),
('55667788990', 'FR7630006000011234567890189', 'FR');

-- ============================================================
-- 2. SVILUPPATORE (15 record, ID espliciti 1-15)
-- ============================================================
INSERT INTO Sviluppatore (Nome, Email, Sito_web, Fiscalita) VALUES
('AppVision Srl',      'info@appvision.it',        'https://www.appvision.it',     '01234567890'),
('Digital Dreams SpA', 'contatti@digitaldreams.it', 'https://www.digitaldreams.it', '12345678901'),
('CodeMasters Italia', 'support@codemasters.it',   'https://www.codemasters.it',   '23456789012'),
('TechnoApp Srl',      'hello@technoapp.it',       'https://www.technoapp.it',     '34567890123'),
('InnovaCode SpA',     'dev@innovacode.it',        'https://www.innovacode.it',    '45678901234'),
('CreativeApps Srl',   'info@creativeapps.it',     'https://www.creativeapps.it',  '56789012345'),
('SmartSoft Italia',   'team@smartsoft.it',        'https://www.smartsoft.it',     '67890123456'),
('ProDev Solutions',   'contact@prodev.it',        'https://www.prodev.it',        '78901234567'),
('ByteForge Srl',      'support@byteforge.it',     'https://www.byteforge.it',     '89012345678'),
('NexGen Apps',        'info@nexgenapps.it',       'https://www.nexgenapps.it',    '90123456789'),
('AlphaCode Srl',      'dev@alphacode.it',         'https://www.alphacode.it',     '11223344556'),
('MobileFirst SpA',    'hello@mobilefirst.it',     'https://www.mobilefirst.it',   '22334455667'),
('EuroTech Solutions', 'info@eurotech.it',         'https://www.eurotech.it',      '33445566778'),
('CloudNet GmbH',      'kontakt@cloudnet.de',      'https://www.cloudnet.de',      '44556677889'),
('DataFlow SAS',       'contact@dataflow.fr',      'https://www.dataflow.fr',      '55667788990');



-- ============================================================
-- 3. PIATTAFORMA (4 record)
-- ============================================================
INSERT INTO Piattaforma (Nome, Produttore) VALUES
('Android',   'Google'),
('iOS',       'Apple'),
('HarmonyOS', 'Huawei'),
('Windows',   'Microsoft');

-- ============================================================
-- 4. CATEGORIA (12 record)
-- ============================================================
INSERT INTO Categoria (Nome) VALUES
('Giochi'), ('Produttivita'), ('Social'), ('Fitness'),
('Musica'), ('Fotografia'), ('Educazione'), ('Intrattenimento'),
('Finanza'), ('Viaggi'), ('Notizie'), ('Stile di vita');

-- ============================================================
-- 5. APPLICAZIONE (40 record: 20 Gratis + 20 Premium)
-- ============================================================
INSERT INTO Applicazione (Sviluppatore, Dimensione, Versione, Nome, Data_Rilascio, Num_Download, Tipo, Giorni_Prova, Prezzo, Frequenza_Annunci, Banner) VALUES
-- === GRATIS (1-20) ===
(1,   45.50, '2.1.0', 'FotoSnap',      '2023-03-15', 5, 'Gratuita', NULL, NULL, 5,  TRUE),
(2,   22.30, '1.5.2', 'MeteoOggi',     '2023-01-10', 5, 'Gratuita', NULL, NULL, 3,  TRUE),
(3,   78.00, '3.0.1', 'GiocoQuiz',     '2022-11-20', 6, 'Gratuita', NULL, NULL, 8,  TRUE),
(4,   35.20, '2.3.0', 'FitTracker',    '2023-05-08', 4, 'Gratuita', NULL, NULL, 4,  FALSE),
(5,   18.90, '1.2.0', 'NotizieFlash',  '2023-07-01', 4, 'Gratuita', NULL, NULL, 6,  TRUE),
(6,   52.80, '4.1.0', 'MusicaMix',     '2022-09-15', 7, 'Gratuita', NULL, NULL, 10, TRUE),
(7,   30.50, '2.8.0', 'ChatAmici',     '2022-06-20', 6, 'Gratuita', NULL, NULL, 2,  FALSE),
(8,   15.60, '1.9.5', 'AppuntiVeloci', '2023-02-28', 5,  'Gratuita', NULL, NULL, 3,  FALSE),
(9,   88.40, '3.2.0', 'VideoFun',      '2022-12-10', 6, 'Gratuita', NULL, NULL, 7,  TRUE),
(10,  12.30, '1.4.0', 'CalcolaSpese',  '2023-04-18', 4, 'Gratuita', NULL, NULL, 4,  TRUE),
(11,  42.70, '2.0.0', 'MappaViaggi',   '2023-08-05', 5, 'Gratuita', NULL, NULL, 5,  FALSE),
(12,  55.90, '3.1.0', 'LinguaFacile',  '2022-10-12', 3, 'Gratuita', NULL, NULL, 6,  TRUE),
(13,  65.00, '2.5.0', 'GiocoCarte',    '2023-01-25', 3, 'Gratuita', NULL, NULL, 9,  TRUE),
(1,   28.40, '1.7.0', 'SocialPost',    '2023-06-14', 5, 'Gratuita', NULL, NULL, 4,  FALSE),
(2,   20.10, '2.2.0', 'RadioItalia',   '2023-03-30', 5, 'Gratuita', NULL, NULL, 3,  TRUE),
(3,   38.60, '1.6.0', 'FitnessHome',   '2023-09-01', 5, 'Gratuita', NULL, NULL, 5,  FALSE),
(4,   25.80, '2.0.1', 'NotizieMondo',  '2023-02-15', 5, 'Gratuita', NULL, NULL, 7,  TRUE),
(5,   48.20, '1.8.0', 'CucinaFacile',  '2023-04-22', 3, 'Gratuita', NULL, NULL, 4,  TRUE),
(6,   58.30, '2.4.0', 'FotoArte',      '2023-07-18', 5, 'Gratuita', NULL, NULL, 6,  TRUE),
(7,   19.70, '1.3.0', 'MeditaZen',     '2023-08-25', 4,  'Gratuita', NULL, NULL, 2,  FALSE),
-- === PREMIUM (21-40) ===
(8,  120.00, '3.0.0', 'ProEditor',      '2023-06-01', 3,  'Premium', 7,  2.99,  NULL, NULL),
(9,   32.50, '2.1.0', 'TaskMaster',     '2023-04-10', 4,  'Premium', 14, 4.99,  NULL, NULL),
(10, 150.00, '4.0.0', 'GiocoEpico',     '2022-08-20', 3,  'Premium', 3,  1.99,  NULL, NULL),
(11,  62.80, '3.5.0', 'FitnessPro',     '2023-01-15', 3,  'Premium', 30, 9.99,  NULL, NULL),
(12,  45.60, '2.7.0', 'MusicaPro',      '2023-05-20', 2,  'Premium', 7,  3.99,  NULL, NULL),
(13,  38.90, '1.9.0', 'SocialVIP',      '2023-03-05', 6,  'Premium', 14, 5.99,  NULL, NULL),
(14,  28.30, '2.3.0', 'CloudDrive',     '2023-02-18', 5,  'Premium', 30, 7.99,  NULL, NULL),
(15,  72.40, '3.2.0', 'PuzzleMania',    '2022-11-08', 4,  'Premium', 3,  0.99,  NULL, NULL),
(1,  180.00, '4.1.0', 'StudioVideo',    '2023-07-10', 4,  'Premium', 7,  14.99, NULL, NULL),
(2,   22.10, '1.5.0', 'FinanzaPro',     '2023-08-15', 4,  'Premium', 14, 2.49,  NULL, NULL),
(3,   55.40, '2.6.0', 'ViaggioPlus',    '2023-09-20', 3,  'Premium', 7,  6.99,  NULL, NULL),
(4,   40.20, '2.0.0', 'ScuolaPlus',     '2023-06-25', 3,  'Premium', 14, 3.49,  NULL, NULL),
(5,  200.00, '5.0.0', 'StrategiaWar',   '2022-07-30', 3,  'Premium', 7,  11.99, NULL, NULL),
(6,   18.50, '1.4.0', 'DietaFit',       '2023-10-05', 2,  'Premium', 7,  1.49,  NULL, NULL),
(7,   35.70, '2.2.0', 'PodcastPro',     '2023-05-12', 2,  'Premium', 14, 4.49,  NULL, NULL),
(8,   95.30, '3.8.0', 'OfficeSuite',    '2023-01-08', 5,  'Premium', 30, 8.99,  NULL, NULL),
(9,  250.00, '4.5.0', 'DesignStudio',   '2023-04-15', 3,  'Premium', 14, 19.99, NULL, NULL),
(10,  16.80, '1.2.0', 'ContoFacile',    '2023-11-01', 4,  'Premium', 7,  2.99,  NULL, NULL),
(11,  68.90, '2.9.0', 'CorsoOnline',    '2023-03-22', 3,  'Premium', 14, 5.49,  NULL, NULL),
(12, 130.00, '3.3.0', 'GiocoAvventura', '2023-08-08', 3,  'Premium', 7,  3.99,  NULL, NULL);

-- ============================================================
-- 6. CLASSIFICAZIONE (56 record, alcune app in piu categorie)
-- ============================================================
INSERT INTO Classificazione (Applicazione, Categoria) VALUES
(1,  'Fotografia'),
(2,  'Stile di vita'), (2,  'Notizie'),
(3,  'Giochi'),        (3,  'Educazione'),
(4,  'Fitness'),       (4,  'Stile di vita'),
(5,  'Notizie'),
(6,  'Musica'),        (6,  'Intrattenimento'),
(7,  'Social'),
(8,  'Produttivita'),
(9,  'Intrattenimento'),
(10, 'Finanza'),       (10, 'Produttivita'),
(11, 'Viaggi'),
(12, 'Educazione'),
(13, 'Giochi'),
(14, 'Social'),        (14, 'Fotografia'),
(15, 'Musica'),
(16, 'Fitness'),
(17, 'Notizie'),       (17, 'Intrattenimento'),
(18, 'Stile di vita'),
(19, 'Fotografia'),    (19, 'Intrattenimento'),
(20, 'Stile di vita'), (20, 'Fitness'),
(21, 'Fotografia'),    (21, 'Produttivita'),
(22, 'Produttivita'),
(23, 'Giochi'),
(24, 'Fitness'),
(25, 'Musica'),
(26, 'Social'),
(27, 'Produttivita'),  (27, 'Finanza'),
(28, 'Giochi'),        (28, 'Educazione'),
(29, 'Intrattenimento'),(29, 'Fotografia'),
(30, 'Finanza'),
(31, 'Viaggi'),
(32, 'Educazione'),
(33, 'Giochi'),
(34, 'Fitness'),       (34, 'Stile di vita'),
(35, 'Intrattenimento'),(35, 'Musica'),
(36, 'Produttivita'),
(37, 'Fotografia'),
(38, 'Finanza'),
(39, 'Educazione'),
(40, 'Giochi'),        (40, 'Intrattenimento');

-- ============================================================
-- 7. UTENTE (50 record)
-- ============================================================
INSERT INTO Utente (Nickname, Email, Data_Iscrizione) VALUES
('marco_92',      'marco.rossi92@gmail.com',         '2022-01-15'),
('alex_gamer',    'alex.gaming@outlook.com',          '2022-03-20'),
('giulia_b',      'giulia.bianchi@gmail.com',         '2022-05-10'),
('luca_m',        'luca.moretti@yahoo.it',            '2022-02-28'),
('sofia_v',       'sofia.verdi@gmail.com',            '2022-06-15'),
('andrea_f',      'andrea.ferraro@libero.it',         '2022-04-22'),
('elena_c',       'elena.colombo@gmail.com',          '2022-07-08'),
('davide_p',      'davide.pellegrini@outlook.it',     '2022-03-14'),
('chiara_l',      'chiara.lombardi@gmail.com',        '2022-08-19'),
('matteo_g',      'matteo.greco@yahoo.it',            '2022-05-30'),
('sara_t',        'sara.testa@gmail.com',             '2022-09-12'),
('alessandro_n',  'alessandro.neri@libero.it',        '2022-01-05'),
('francesca_d',   'francesca.damico@gmail.com',       '2022-10-25'),
('giuseppe_z',    'giuseppe.zanetti@outlook.it',      '2022-02-14'),
('valentina_s',   'valentina.serra@gmail.com',        '2022-11-08'),
('roberto_a',     'roberto.amato@yahoo.it',           '2022-04-30'),
('martina_e',     'martina.esposito@gmail.com',       '2022-06-22'),
('simone_o',      'simone.orlando@libero.it',         '2022-12-01'),
('laura_i',       'laura.izzo@gmail.com',             '2022-03-18'),
('fabio_u',       'fabio.uberti@outlook.it',          '2022-07-14'),
('anna_r',        'anna.romano@gmail.com',            '2022-08-05'),
('giovanni_b',    'giovanni.bruno@yahoo.it',          '2022-01-20'),
('alice_m',       'alice.marini@gmail.com',           '2022-09-28'),
('lorenzo_v',     'lorenzo.vitale@libero.it',         '2022-02-10'),
('federica_f',    'federica.fabbri@gmail.com',        '2022-10-15'),
('nicola_c',      'nicola.costa@outlook.it',          '2022-05-05'),
('elisa_p',       'elisa.parisi@gmail.com',           '2022-11-20'),
('daniele_l',     'daniele.leone@yahoo.it',           '2022-04-08'),
('claudia_g',     'claudia.galli@gmail.com',          '2022-06-30'),
('stefano_t',     'stefano.turco@libero.it',          '2022-12-18'),
('silvia_n',      'silvia.napoli@gmail.com',          '2022-03-25'),
('paolo_d',       'paolo.demarco@outlook.it',         '2022-07-22'),
('maria_z',       'maria.zappa@gmail.com',            '2022-08-15'),
('emanuele_s',    'emanuele.silvestri@yahoo.it',      '2022-01-30'),
('cristina_a',    'cristina.alberti@gmail.com',        '2022-09-08'),
('antonio_e',     'antonio.ercolano@libero.it',       '2022-02-22'),
('angela_o',      'angela.oliveri@gmail.com',          '2022-10-30'),
('filippo_i',     'filippo.innocenti@outlook.it',     '2022-05-18'),
('rosa_u',        'rosa.urbano@gmail.com',             '2022-11-12'),
('vincenzo_r',    'vincenzo.ricci@yahoo.it',           '2022-04-15'),
('patrizia_b',    'patrizia.bassi@gmail.com',          '2022-06-08'),
('riccardo_m',    'riccardo.mancini@libero.it',       '2022-12-28'),
('irene_v',       'irene.valentini@gmail.com',         '2022-03-10'),
('pietro_f',      'pietro.fontana@outlook.it',        '2022-07-28'),
('carla_c',       'carla.caruso@gmail.com',            '2022-08-22'),
('tommaso_p',     'tommaso.pagano@yahoo.it',           '2022-01-12'),
('teresa_l',      'teresa.longo@gmail.com',            '2022-09-15'),
('enrico_g',      'enrico.gentile@libero.it',         '2022-02-05'),
('serena_t',      'serena.tosi@gmail.com',             '2022-10-20'),
('barbara_d',     'barbara.deluca@outlook.it',        '2022-05-25');

-- ============================================================
-- 8. DISPOSITIVO (61 record)
-- ============================================================
INSERT INTO Dispositivo (IMEI, Utente, Marca, Modello, Piattaforma, Versione_Installata) VALUES
('350000000000001', 'marco_92',     'Samsung',   'Galaxy S24',        'Android',   '14.0'),
('350000000000002', 'marco_92',     'Apple',     'iPhone 15 Pro',     'iOS',       '17.0'),
('350000000000003', 'marco_92',     'Microsoft', 'Surface Pro 9',     'Windows',   '11.0'),
('350000000000004', 'alex_gamer',   'Google',    'Pixel 8',           'Android',   '14.0'),
('350000000000005', 'alex_gamer',   'Apple',     'iPhone 14',         'iOS',       '17.0'),
('350000000000006', 'alex_gamer',   'Huawei',    'Mate 60',           'HarmonyOS', '4.0'),
('350000000000007', 'giulia_b',     'Xiaomi',    'Redmi Note 13',     'Android',   '13.0'),
('350000000000008', 'giulia_b',     'Apple',     'iPhone 15',         'iOS',       '17.0'),
('350000000000009', 'luca_m',       'Samsung',   'Galaxy A54',        'Android',   '14.0'),
('350000000000010', 'sofia_v',      'Apple',     'iPhone 13',         'iOS',       '16.0'),
('350000000000011', 'andrea_f',     'OnePlus',   '12',                'Android',   '14.0'),
('350000000000012', 'andrea_f',     'Apple',     'iPhone 15 Pro Max', 'iOS',       '17.0'),
('350000000000013', 'elena_c',      'Samsung',   'Galaxy S23',        'Android',   '13.0'),
('350000000000014', 'davide_p',     'Apple',     'iPhone 14 Pro',     'iOS',       '17.0'),
('350000000000015', 'chiara_l',     'Google',    'Pixel 7a',          'Android',   '13.0'),
('350000000000016', 'matteo_g',     'Apple',     'iPhone 12',         'iOS',       '16.0'),
('350000000000017', 'sara_t',       'OnePlus',   'Nord 3',            'Android',   '13.0'),
('350000000000018', 'sara_t',       'Apple',     'iPhone 14 Plus',    'iOS',       '17.0'),
('350000000000019', 'alessandro_n', 'Samsung',   'Galaxy A34',        'Android',   '13.0'),
('350000000000020', 'francesca_d',  'Apple',     'iPhone 15',         'iOS',       '17.0'),
('350000000000021', 'giuseppe_z',   'Google',    'Pixel 8 Pro',       'Android',   '14.0'),
('350000000000022', 'valentina_s',  'Apple',     'iPhone 13 Pro',     'iOS',       '17.0'),
('350000000000023', 'roberto_a',    'Samsung',   'Galaxy S24 Ultra',  'Android',   '14.0'),
('350000000000024', 'martina_e',    'OnePlus',   '11',                'Android',   '13.0'),
('350000000000025', 'martina_e',    'Huawei',    'P60',               'HarmonyOS', '4.0'),
('350000000000026', 'simone_o',     'Xiaomi',    'Redmi 12',          'Android',   '13.0'),
('350000000000027', 'laura_i',      'Apple',     'iPhone 13 Mini',    'iOS',       '16.0'),
('350000000000028', 'fabio_u',      'Samsung',   'Galaxy A14',        'Android',   '13.0'),
('350000000000029', 'anna_r',       'Apple',     'iPhone 14',         'iOS',       '17.0'),
('350000000000030', 'anna_r',       'Huawei',    'Nova 12',           'HarmonyOS', '4.0'),
('350000000000031', 'giovanni_b',   'Apple',     'iPhone 15',         'iOS',       '17.0'),
('350000000000032', 'alice_m',      'Apple',     'iPad Air',          'iOS',       '17.0'),
('350000000000033', 'lorenzo_v',    'Samsung',   'Galaxy Z Flip5',    'Android',   '14.0'),
('350000000000034', 'federica_f',   'Apple',     'iPhone 13 Pro Max', 'iOS',       '17.0'),
('350000000000035', 'nicola_c',     'Xiaomi',    '14',                'Android',   '14.0'),
('350000000000036', 'elisa_p',      'Apple',     'iPhone 15 Pro',     'iOS',       '17.0'),
('350000000000037', 'daniele_l',    'Google',    'Pixel 7',           'Android',   '13.0'),
('350000000000038', 'claudia_g',    'Apple',     'iPhone 14 Pro Max', 'iOS',       '17.0'),
('350000000000039', 'stefano_t',    'Samsung',   'Galaxy S23 FE',     'Android',   '14.0'),
('350000000000040', 'silvia_n',     'Apple',     'iPhone 13',         'iOS',       '16.0'),
('350000000000041', 'silvia_n',     'Lenovo',    'ThinkPad X1',       'Windows',   '11.0'),
('350000000000042', 'paolo_d',      'Huawei',    'Mate 60 Pro',       'HarmonyOS', '4.0'),
('350000000000043', 'maria_z',      'Huawei',    'P60 Pro',           'HarmonyOS', '4.0'),
('350000000000044', 'emanuele_s',   'Huawei',    'Nova 12 Ultra',     'HarmonyOS', '4.0'),
('350000000000045', 'cristina_a',   'Huawei',    'Mate X5',           'HarmonyOS', '4.0'),
('350000000000046', 'antonio_e',    'Huawei',    'P50 Pro',           'HarmonyOS', '3.0'),
('350000000000047', 'angela_o',     'Huawei',    'Nova 11',           'HarmonyOS', '3.0'),
('350000000000048', 'filippo_i',    'Huawei',    'Mate 50',           'HarmonyOS', '3.0'),
('350000000000049', 'rosa_u',       'Dell',      'XPS 13',            'Windows',   '11.0'),
('350000000000050', 'vincenzo_r',   'HP',        'Spectre x360',      'Windows',   '11.0'),
('350000000000051', 'patrizia_b',   'Asus',      'ZenBook 14',        'Windows',   '11.0'),
('350000000000052', 'riccardo_m',   'Microsoft', 'Surface Laptop 5',  'Windows',   '11.0'),
('350000000000053', 'irene_v',      'Lenovo',    'Yoga 9i',           'Windows',   '11.0'),
('350000000000054', 'pietro_f',     'Dell',      'Inspiron 16',       'Windows',   '11.0'),
('350000000000055', 'carla_c',      'HP',        'Pavilion Plus',     'Windows',   '11.0'),
('350000000000056', 'tommaso_p',    'Xiaomi',    'Poco F5',           'Android',   '13.0'),
('350000000000057', 'teresa_l',     'OnePlus',   'Nord CE 3',         'Android',   '13.0'),
('350000000000058', 'enrico_g',     'Samsung',   'Galaxy A54',        'Android',   '14.0'),
('350000000000059', 'enrico_g',     'Asus',      'Vivobook 15',       'Windows',   '11.0'),
('350000000000060', 'serena_t',     'Apple',     'iPhone 12 Mini',    'iOS',       '16.0'),
('350000000000061', 'barbara_d',    'Google',    'Pixel 6a',          'Android',   '13.0');

-- ============================================================
-- 9. COMPATIBILITA (108 record)
-- ============================================================
INSERT INTO Compatibilita (Piattaforma, Applicazione, Versione_Minima) VALUES
('Android', 1, '11.0'), ('iOS', 1, '15.0'),
('Android', 2, '10.0'), ('iOS', 2, '14.0'),
('Android', 3, '11.0'), ('iOS', 3, '15.0'),
('Android', 4, '12.0'), ('iOS', 4, '15.0'),
('Android', 5, '10.0'), ('iOS', 5, '14.0'),
('Android', 6, '11.0'), ('iOS', 6, '15.0'), ('HarmonyOS', 6, '3.0'),
('Android', 7, '10.0'), ('iOS', 7, '14.0'), ('HarmonyOS', 7, '2.0'),
('Android', 8, '11.0'), ('iOS', 8, '15.0'), ('HarmonyOS', 8, '3.0'),
('Android', 9, '12.0'), ('iOS', 9, '15.0'), ('HarmonyOS', 9, '3.0'),
('Android', 10, '10.0'), ('iOS', 10, '14.0'), ('HarmonyOS', 10, '2.0'),
('Android', 11, '11.0'), ('iOS', 11, '15.0'), ('Windows', 11, '10.0'),
('Android', 12, '10.0'), ('iOS', 12, '14.0'), ('Windows', 12, '10.0'),
('Android', 13, '11.0'), ('iOS', 13, '15.0'), ('Windows', 13, '10.0'),
('Android', 14, '12.0'), ('iOS', 14, '15.0'), ('Windows', 14, '11.0'),
('Android', 15, '10.0'), ('iOS', 15, '14.0'), ('Windows', 15, '10.0'),
('Android', 16, '12.0'), ('HarmonyOS', 16, '3.0'), ('Windows', 16, '11.0'),
('Android', 17, '11.0'), ('HarmonyOS', 17, '3.0'), ('Windows', 17, '10.0'),
('Android', 18, '10.0'), ('HarmonyOS', 18, '2.0'), ('Windows', 18, '10.0'),
('iOS', 19, '15.0'), ('HarmonyOS', 19, '3.0'),
('iOS', 20, '14.0'), ('HarmonyOS', 20, '2.0'),
('Android', 21, '12.0'), ('iOS', 21, '16.0'),
('Android', 22, '11.0'), ('iOS', 22, '15.0'),
('Android', 23, '12.0'), ('iOS', 23, '16.0'),
('Android', 24, '12.0'), ('iOS', 24, '15.0'),
('Android', 25, '11.0'), ('iOS', 25, '15.0'),
('Android', 26, '11.0'), ('iOS', 26, '15.0'), ('HarmonyOS', 26, '3.0'), ('Windows', 26, '11.0'),
('Android', 27, '10.0'), ('iOS', 27, '14.0'), ('HarmonyOS', 27, '2.0'), ('Windows', 27, '10.0'),
('Android', 28, '11.0'), ('iOS', 28, '15.0'), ('HarmonyOS', 28, '3.0'), ('Windows', 28, '10.0'),
('Android', 29, '12.0'), ('iOS', 29, '16.0'), ('HarmonyOS', 29, '3.0'), ('Windows', 29, '11.0'),
('Android', 30, '10.0'), ('iOS', 30, '14.0'), ('HarmonyOS', 30, '2.0'), ('Windows', 30, '10.0'),
('iOS', 31, '16.0'), ('HarmonyOS', 31, '3.0'),
('iOS', 32, '15.0'), ('HarmonyOS', 32, '3.0'),
('iOS', 33, '16.0'), ('HarmonyOS', 33, '3.0'),
('iOS', 34, '15.0'), ('HarmonyOS', 34, '3.0'),
('iOS', 35, '15.0'), ('HarmonyOS', 35, '3.0'),
('Android', 36, '12.0'), ('HarmonyOS', 36, '3.0'), ('Windows', 36, '11.0'),
('Android', 37, '12.0'), ('HarmonyOS', 37, '3.0'), ('Windows', 37, '11.0'),
('Android', 38, '11.0'), ('HarmonyOS', 38, '3.0'), ('Windows', 38, '10.0'),
('Android', 39, '12.0'), ('iOS', 39, '16.0'), ('HarmonyOS', 39, '4.0'),
('Android', 40, '11.0'), ('iOS', 40, '15.0'), ('HarmonyOS', 40, '3.0');

-- ============================================================
-- 10. DOWNLOAD (164 record)
-- ============================================================
INSERT INTO Download (Utente, Applicazione, Dispositivo, Data_Ora) VALUES
('marco_92', 1,  '350000000000001', '2024-06-15 09:30:00'),
('marco_92', 3,  '350000000000002', '2024-07-20 14:00:00'),
('marco_92', 11, '350000000000003', '2024-08-10 11:00:00'),
('marco_92', 14, '350000000000001', '2024-09-05 16:30:00'),
('marco_92', 21, '350000000000002', '2024-10-01 08:45:00'),
('marco_92', 22, '350000000000001', '2024-11-15 10:00:00'),
('marco_92', 26, '350000000000003', '2025-01-10 13:00:00'),
('marco_92', 27, '350000000000002', '2025-02-20 09:30:00'),
('marco_92', 29, '350000000000001', '2025-03-15 17:00:00'),
('marco_92', 13, '350000000000003', '2025-04-01 12:00:00'),
('alex_gamer', 3,  '350000000000004', '2024-05-10 10:00:00'),
('alex_gamer', 13, '350000000000004', '2024-06-20 15:30:00'),
('alex_gamer', 6,  '350000000000006', '2024-07-15 11:00:00'),
('alex_gamer', 9,  '350000000000005', '2024-08-25 14:00:00'),
('alex_gamer', 23, '350000000000004', '2024-09-30 09:00:00'),
('alex_gamer', 28, '350000000000005', '2024-11-05 16:00:00'),
('alex_gamer', 33, '350000000000006', '2025-01-20 10:30:00'),
('alex_gamer', 40, '350000000000004', '2025-02-14 13:00:00'),
('alex_gamer', 39, '350000000000005', '2025-03-10 08:00:00'),
('alex_gamer', 7,  '350000000000006', '2025-04-05 18:00:00'),
('giulia_b', 2,  '350000000000008', '2024-08-10 08:30:00'),
('giulia_b', 6,  '350000000000007', '2024-10-15 11:00:00'),
('giulia_b', 22, '350000000000008', '2025-01-20 16:00:00'),
('luca_m', 1,  '350000000000009', '2024-07-05 09:15:00'),
('luca_m', 8,  '350000000000009', '2024-09-20 12:30:00'),
('luca_m', 25, '350000000000009', '2025-02-10 10:00:00'),
('sofia_v', 4,  '350000000000010', '2024-06-20 07:45:00'),
('sofia_v', 19, '350000000000010', '2024-09-15 13:00:00'),
('sofia_v', 24, '350000000000010', '2025-01-05 11:30:00'),
('andrea_f', 5,  '350000000000011', '2024-08-18 15:00:00'),
('andrea_f', 9,  '350000000000012', '2024-10-30 17:00:00'),
('andrea_f', 21, '350000000000011', '2025-02-20 08:00:00'),
('elena_c', 1,  '350000000000013', '2024-07-15 10:00:00'),
('elena_c', 17, '350000000000013', '2024-10-05 14:00:00'),
('elena_c', 36, '350000000000013', '2025-03-01 09:30:00'),
('davide_p', 3,  '350000000000014', '2024-06-25 11:00:00'),
('davide_p', 12, '350000000000014', '2024-09-10 08:30:00'),
('davide_p', 31, '350000000000014', '2025-01-15 16:00:00'),
('chiara_l', 6,  '350000000000015', '2024-08-05 09:00:00'),
('chiara_l', 16, '350000000000015', '2024-11-10 12:00:00'),
('chiara_l', 23, '350000000000015', '2025-02-05 10:30:00'),
('matteo_g', 7,  '350000000000016', '2024-07-10 13:00:00'),
('matteo_g', 20, '350000000000016', '2024-10-20 15:00:00'),
('matteo_g', 34, '350000000000016', '2025-01-25 11:00:00'),
('sara_t', 2,  '350000000000017', '2024-08-20 08:00:00'),
('sara_t', 15, '350000000000018', '2024-11-12 14:30:00'),
('sara_t', 30, '350000000000017', '2025-03-15 09:00:00'),
('alessandro_n', 1,  '350000000000019', '2024-06-10 08:00:00'),
('alessandro_n', 16, '350000000000019', '2024-09-01 10:00:00'),
('alessandro_n', 36, '350000000000019', '2025-02-15 12:00:00'),
('francesca_d', 3,  '350000000000020', '2024-07-22 09:00:00'),
('francesca_d', 19, '350000000000020', '2024-10-08 11:00:00'),
('francesca_d', 35, '350000000000020', '2025-01-30 13:00:00'),
('giuseppe_z', 5,  '350000000000021', '2024-08-12 10:00:00'),
('giuseppe_z', 18, '350000000000021', '2024-11-05 12:00:00'),
('giuseppe_z', 38, '350000000000021', '2025-03-08 14:00:00'),
('valentina_s', 7,  '350000000000022', '2024-06-30 11:00:00'),
('valentina_s', 20, '350000000000022', '2024-09-25 13:00:00'),
('valentina_s', 32, '350000000000022', '2025-02-10 15:00:00'),
('roberto_a', 9,  '350000000000023', '2024-07-18 12:00:00'),
('roberto_a', 17, '350000000000023', '2024-10-15 14:00:00'),
('roberto_a', 40, '350000000000023', '2025-03-12 16:00:00'),
('martina_e', 2,  '350000000000024', '2024-08-28 08:30:00'),
('martina_e', 6,  '350000000000025', '2024-11-20 10:30:00'),
('martina_e', 26, '350000000000024', '2025-03-15 12:30:00'),
('simone_o', 4,  '350000000000026', '2024-07-08 09:30:00'),
('simone_o', 8,  '350000000000026', '2024-10-22 11:30:00'),
('simone_o', 22, '350000000000026', '2025-02-18 13:30:00'),
('laura_i', 6,  '350000000000027', '2024-08-15 10:30:00'),
('laura_i', 14, '350000000000027', '2024-11-08 12:30:00'),
('laura_i', 25, '350000000000027', '2025-01-22 14:30:00'),
('fabio_u', 11, '350000000000028', '2024-07-25 11:30:00'),
('fabio_u', 17, '350000000000028', '2024-10-28 13:30:00'),
('fabio_u', 24, '350000000000028', '2025-02-22 15:30:00'),
('anna_r', 10, '350000000000029', '2024-08-08 12:30:00'),
('anna_r', 19, '350000000000030', '2024-11-15 14:30:00'),
('anna_r', 33, '350000000000029', '2025-03-05 16:30:00'),
('giovanni_b', 1,  '350000000000031', '2024-06-18 08:00:00'),
('giovanni_b', 7,  '350000000000031', '2024-09-12 10:00:00'),
('giovanni_b', 31, '350000000000031', '2025-01-08 12:00:00'),
('alice_m', 2,  '350000000000032', '2024-07-14 09:00:00'),
('alice_m', 12, '350000000000032', '2024-10-06 11:00:00'),
('alice_m', 32, '350000000000032', '2025-02-12 13:00:00'),
('lorenzo_v', 3,  '350000000000033', '2024-08-22 10:00:00'),
('lorenzo_v', 8,  '350000000000033', '2024-11-02 12:00:00'),
('lorenzo_v', 23, '350000000000033', '2025-03-09 14:00:00'),
('federica_f', 4,  '350000000000034', '2024-06-28 11:00:00'),
('federica_f', 15, '350000000000034', '2024-09-18 13:00:00'),
('federica_f', 34, '350000000000034', '2025-01-12 15:00:00'),
('nicola_c', 5,  '350000000000035', '2024-07-30 12:00:00'),
('nicola_c', 14, '350000000000035', '2024-10-18 14:00:00'),
('nicola_c', 21, '350000000000035', '2025-02-08 16:00:00'),
('elisa_p', 6,  '350000000000036', '2024-08-30 08:30:00'),
('elisa_p', 20, '350000000000036', '2024-11-22 10:30:00'),
('elisa_p', 35, '350000000000036', '2025-03-18 12:30:00'),
('daniele_l', 8,  '350000000000037', '2024-07-12 09:30:00'),
('daniele_l', 16, '350000000000037', '2024-10-12 11:30:00'),
('daniele_l', 27, '350000000000037', '2025-01-18 13:30:00'),
('claudia_g', 9,  '350000000000038', '2024-08-02 10:30:00'),
('claudia_g', 19, '350000000000038', '2024-11-25 12:30:00'),
('claudia_g', 33, '350000000000038', '2025-02-28 14:30:00'),
('stefano_t', 10, '350000000000039', '2024-06-22 11:30:00'),
('stefano_t', 18, '350000000000039', '2024-09-28 13:30:00'),
('stefano_t', 30, '350000000000039', '2025-01-28 15:30:00'),
('silvia_n', 15, '350000000000040', '2024-08-12 12:30:00'),
('silvia_n', 11, '350000000000041', '2024-11-18 14:30:00'),
('silvia_n', 26, '350000000000041', '2025-03-22 16:30:00'),
('paolo_d', 6,  '350000000000042', '2024-07-20 08:00:00'),
('paolo_d', 19, '350000000000042', '2024-10-10 10:00:00'),
('paolo_d', 31, '350000000000042', '2025-02-05 12:00:00'),
('maria_z', 7,  '350000000000043', '2024-08-25 09:00:00'),
('maria_z', 20, '350000000000043', '2024-11-12 11:00:00'),
('maria_z', 32, '350000000000043', '2025-03-02 13:00:00'),
('emanuele_s', 8,  '350000000000044', '2024-06-15 10:00:00'),
('emanuele_s', 16, '350000000000044', '2024-09-08 12:00:00'),
('emanuele_s', 37, '350000000000044', '2025-01-22 14:00:00'),
('cristina_a', 9,  '350000000000045', '2024-07-28 11:00:00'),
('cristina_a', 17, '350000000000045', '2024-10-25 13:00:00'),
('cristina_a', 38, '350000000000045', '2025-02-18 15:00:00'),
('antonio_e', 10, '350000000000046', '2024-08-18 12:00:00'),
('antonio_e', 18, '350000000000046', '2024-11-28 14:00:00'),
('antonio_e', 39, '350000000000046', '2025-03-12 16:00:00'),
('angela_o', 26, '350000000000047', '2024-09-05 08:30:00'),
('angela_o', 27, '350000000000047', '2024-12-10 10:30:00'),
('angela_o', 36, '350000000000047', '2025-03-20 12:30:00'),
('filippo_i', 28, '350000000000048', '2024-07-15 09:30:00'),
('filippo_i', 29, '350000000000048', '2024-10-20 11:30:00'),
('filippo_i', 40, '350000000000048', '2025-02-25 13:30:00'),
('rosa_u', 11, '350000000000049', '2024-08-05 10:30:00'),
('rosa_u', 26, '350000000000049', '2024-11-08 12:30:00'),
('rosa_u', 36, '350000000000049', '2025-03-15 14:30:00'),
('vincenzo_r', 12, '350000000000050', '2024-06-28 11:30:00'),
('vincenzo_r', 27, '350000000000050', '2024-10-02 13:30:00'),
('vincenzo_r', 37, '350000000000050', '2025-01-30 15:30:00'),
('patrizia_b', 13, '350000000000051', '2024-07-22 12:30:00'),
('patrizia_b', 28, '350000000000051', '2024-10-28 14:30:00'),
('patrizia_b', 38, '350000000000051', '2025-02-22 16:30:00'),
('riccardo_m', 14, '350000000000052', '2024-08-15 08:00:00'),
('riccardo_m', 29, '350000000000052', '2024-11-18 10:00:00'),
('riccardo_m', 36, '350000000000052', '2025-03-10 12:00:00'),
('irene_v', 15, '350000000000053', '2024-07-08 09:00:00'),
('irene_v', 30, '350000000000053', '2024-10-15 11:00:00'),
('irene_v', 37, '350000000000053', '2025-01-25 13:00:00'),
('pietro_f', 16, '350000000000054', '2024-08-28 10:00:00'),
('pietro_f', 26, '350000000000054', '2024-11-25 12:00:00'),
('pietro_f', 38, '350000000000054', '2025-02-15 14:00:00'),
('carla_c', 17, '350000000000055', '2024-06-12 11:00:00'),
('carla_c', 27, '350000000000055', '2024-09-22 13:00:00'),
('carla_c', 29, '350000000000055', '2025-01-18 15:00:00'),
('tommaso_p', 3,  '350000000000056', '2024-07-15 12:00:00'),
('tommaso_p', 10, '350000000000056', '2024-10-08 14:00:00'),
('tommaso_p', 28, '350000000000056', '2025-02-05 16:00:00'),
('teresa_l', 4,  '350000000000057', '2024-08-10 08:30:00'),
('teresa_l', 14, '350000000000057', '2024-11-05 10:30:00'),
('teresa_l', 39, '350000000000057', '2025-03-05 12:30:00'),
('enrico_g', 5,  '350000000000058', '2024-07-02 09:30:00'),
('enrico_g', 11, '350000000000059', '2024-10-12 11:30:00'),
('enrico_g', 30, '350000000000058', '2025-02-08 13:30:00'),
('serena_t', 7,  '350000000000060', '2024-08-22 10:30:00'),
('serena_t', 15, '350000000000060', '2024-11-15 12:30:00'),
('serena_t', 24, '350000000000060', '2025-03-08 14:30:00'),
('barbara_d', 2,  '350000000000061', '2024-06-05 11:30:00'),
('barbara_d', 9,  '350000000000061', '2024-09-15 13:30:00'),
('barbara_d', 22, '350000000000061', '2025-01-28 15:30:00');

-- ============================================================
-- 11. TRANSAZIONE (60 record)
-- ============================================================
INSERT INTO Transazione (Codice, Utente, Applicazione, Importo, Data_Pagamento, Metodo_Pagamento) VALUES
-- marco_92 (5 transazioni)
('TXN-001', 'marco_92', 21, 2.99,  '2024-10-01 08:40:00', 'Carta di credito'),
('TXN-002', 'marco_92', 22, 4.99,  '2024-11-15 09:55:00', 'PayPal'),
('TXN-003', 'marco_92', 26, 5.99,  '2025-01-10 12:55:00', 'Apple Pay'),
('TXN-004', 'marco_92', 27, 7.99,  '2025-02-20 09:25:00', 'Carta di credito'),
('TXN-005', 'marco_92', 29, 14.99, '2025-03-15 16:55:00', 'Google Pay'),
-- alex_gamer (5 transazioni)
('TXN-006', 'alex_gamer', 23, 1.99,  '2024-09-30 08:55:00', 'Google Pay'),
('TXN-007', 'alex_gamer', 28, 0.99,  '2024-11-05 15:55:00', 'PayPal'),
('TXN-008', 'alex_gamer', 33, 11.99, '2025-01-20 10:25:00', 'Carta di credito'),
('TXN-009', 'alex_gamer', 40, 3.99,  '2025-02-14 12:55:00', 'Carta prepagata'),
('TXN-010', 'alex_gamer', 39, 5.49,  '2025-03-10 07:55:00', 'Apple Pay'),
-- altri utenti (50 transazioni)
('TXN-011', 'giulia_b',     22, 4.99,  '2025-01-20 15:55:00', 'Carta di credito'),
('TXN-012', 'luca_m',       25, 3.99,  '2025-02-10 09:55:00', 'PayPal'),
('TXN-013', 'sofia_v',      24, 9.99,  '2025-01-05 11:25:00', 'Apple Pay'),
('TXN-014', 'andrea_f',     21, 2.99,  '2025-02-20 07:55:00', 'Google Pay'),
('TXN-015', 'elena_c',      36, 8.99,  '2025-03-01 09:25:00', 'Carta di credito'),
('TXN-016', 'davide_p',     31, 6.99,  '2025-01-15 15:55:00', 'Apple Pay'),
('TXN-017', 'chiara_l',     23, 1.99,  '2025-02-05 10:25:00', 'PayPal'),
('TXN-018', 'matteo_g',     34, 1.49,  '2025-01-25 10:55:00', 'Carta di credito'),
('TXN-019', 'sara_t',       30, 2.49,  '2025-03-15 08:55:00', 'Google Pay'),
('TXN-020', 'alessandro_n', 36, 8.99,  '2025-02-15 11:55:00', 'Carta prepagata'),
('TXN-021', 'francesca_d',  35, 4.49,  '2025-01-30 12:55:00', 'Apple Pay'),
('TXN-022', 'giuseppe_z',   38, 2.99,  '2025-03-08 13:55:00', 'Carta di credito'),
('TXN-023', 'valentina_s',  32, 3.49,  '2025-02-10 14:55:00', 'PayPal'),
('TXN-024', 'roberto_a',    40, 3.99,  '2025-03-12 15:55:00', 'Google Pay'),
('TXN-025', 'martina_e',    26, 5.99,  '2025-03-15 12:25:00', 'Carta di credito'),
('TXN-026', 'simone_o',     22, 4.99,  '2025-02-18 13:25:00', 'PayPal'),
('TXN-027', 'laura_i',      25, 3.99,  '2025-01-22 14:25:00', 'Apple Pay'),
('TXN-028', 'fabio_u',      24, 9.99,  '2025-02-22 15:25:00', 'Carta di credito'),
('TXN-029', 'anna_r',       33, 11.99, '2025-03-05 16:25:00', 'Carta prepagata'),
('TXN-030', 'giovanni_b',   31, 6.99,  '2025-01-08 11:55:00', 'Google Pay'),
('TXN-031', 'alice_m',      32, 3.49,  '2025-02-12 12:55:00', 'Apple Pay'),
('TXN-032', 'lorenzo_v',    23, 1.99,  '2025-03-09 13:55:00', 'PayPal'),
('TXN-033', 'federica_f',   34, 1.49,  '2025-01-12 14:55:00', 'Carta di credito'),
('TXN-034', 'nicola_c',     21, 2.99,  '2025-02-08 15:55:00', 'Google Pay'),
('TXN-035', 'elisa_p',      35, 4.49,  '2025-03-18 12:25:00', 'Apple Pay'),
('TXN-036', 'daniele_l',    27, 7.99,  '2025-01-18 13:25:00', 'Carta di credito'),
('TXN-037', 'claudia_g',    33, 11.99, '2025-02-28 14:25:00', 'PayPal'),
('TXN-038', 'stefano_t',    30, 2.49,  '2025-01-28 15:25:00', 'Carta prepagata'),
('TXN-039', 'silvia_n',     26, 5.99,  '2025-03-22 16:25:00', 'Google Pay'),
('TXN-040', 'paolo_d',      31, 6.99,  '2025-02-05 11:55:00', 'Carta di credito'),
('TXN-041', 'maria_z',      32, 3.49,  '2025-03-02 12:55:00', 'Apple Pay'),
('TXN-042', 'emanuele_s',   37, 19.99, '2025-01-22 13:55:00', 'Carta di credito'),
('TXN-043', 'cristina_a',   38, 2.99,  '2025-02-18 14:55:00', 'PayPal'),
('TXN-044', 'antonio_e',    39, 5.49,  '2025-03-12 15:55:00', 'Google Pay'),
('TXN-045', 'angela_o',     26, 5.99,  '2024-09-05 08:25:00', 'Carta di credito'),
('TXN-046', 'angela_o',     27, 7.99,  '2024-12-10 10:25:00', 'PayPal'),
('TXN-047', 'filippo_i',    28, 0.99,  '2024-07-15 09:25:00', 'Google Pay'),
('TXN-048', 'filippo_i',    29, 14.99, '2024-10-20 11:25:00', 'Carta di credito'),
('TXN-049', 'rosa_u',       26, 5.99,  '2024-11-08 12:25:00', 'Apple Pay'),
('TXN-050', 'vincenzo_r',   27, 7.99,  '2024-10-02 13:25:00', 'Carta prepagata'),
('TXN-051', 'patrizia_b',   28, 0.99,  '2024-10-28 14:25:00', 'PayPal'),
('TXN-052', 'riccardo_m',   29, 14.99, '2024-11-18 09:55:00', 'Carta di credito'),
('TXN-053', 'irene_v',      30, 2.49,  '2024-10-15 10:55:00', 'Google Pay'),
('TXN-054', 'pietro_f',     26, 5.99,  '2024-11-25 11:55:00', 'Apple Pay'),
('TXN-055', 'carla_c',      27, 7.99,  '2024-09-22 12:55:00', 'Carta di credito'),
('TXN-056', 'tommaso_p',    28, 0.99,  '2025-02-05 15:55:00', 'PayPal'),
('TXN-057', 'teresa_l',     39, 5.49,  '2025-03-05 12:25:00', 'Carta prepagata'),
('TXN-058', 'enrico_g',     30, 2.49,  '2025-02-08 13:25:00', 'Google Pay'),
('TXN-059', 'serena_t',     24, 9.99,  '2025-03-08 14:25:00', 'Carta di credito'),
('TXN-060', 'barbara_d',    22, 4.99,  '2025-01-28 15:25:00', 'Apple Pay');

-- ============================================================
-- 12. RECENSIONE (70 record)
-- ============================================================
INSERT INTO Recensione (Utente, Applicazione, Voto, Data, Testo) VALUES
-- === marco_92: 6 recensioni (voti variati 2-5) ===
('marco_92', 1,  5, '2024-06-20', 'Applicazione fantastica per le foto! La uso tutti i giorni e non mi stanco mai.'),
('marco_92', 3,  3, '2024-07-25', 'Quiz divertenti ma dopo un po semplic, le domande si ripetono troppo spesso.'),
('marco_92', 21, 4, '2024-10-10', 'Editor professionale con tanti filtri. Manca solo il supporto per i file RAW.'),
('marco_92', 22, 5, '2024-11-20', 'Il miglior task manager in circolazione, organizza tutto alla perfezione!'),
('marco_92', 26, 2, '2025-01-15', 'Community troppo piccola in Italia, pochi contenuti davvero interessanti.'),
('marco_92', 29, 4, '2025-03-20', 'Editing video potente ma richiede un dispositivo molto performante.'),
-- === alex_gamer: 6 recensioni (voti variati 1-5) ===
('alex_gamer', 3,  5, '2024-05-15', 'Il miglior gioco quiz in italiano! Domande sempre aggiornate e stimolanti.'),
('alex_gamer', 23, 4, '2024-10-05', 'Gioco epico con grafica incredibile, qualche lag nelle scene complesse.'),
('alex_gamer', 28, 3, '2024-11-10', 'Puzzle carini ma il livello di difficolta cresce troppo velocemente.'),
('alex_gamer', 33, 5, '2025-01-25', 'Strategia pura, avvincente e ben bilanciata. Un vero capolavoro ludico!'),
('alex_gamer', 40, 4, '2025-02-20', 'Avventura coinvolgente con una bella storia, merita assolutamente il prezzo.'),
('alex_gamer', 6,  1, '2025-04-10', 'Troppa pubblicita tra i brani, impossibile ascoltare musica tranquillamente.'),
-- === altri 58 recensioni ===
('giulia_b', 2,  4, '2024-08-15', 'Previsioni meteo abbastanza accurate e interfaccia bella e intuitiva.'),
('giulia_b', 22, 5, '2025-01-25', 'Il miglior task manager che abbia mai provato, organizza tutto!'),
('luca_m', 1,  5, '2024-07-10', 'Foto incredibili con filtri bellissimi, la consiglio a tutti!'),
('luca_m', 25, 4, '2025-02-15', 'Qualita audio eccellente e catalogo musicale davvero molto vasto.'),
('sofia_v', 4,  5, '2024-06-25', 'Mi ha aiutato tantissimo a tenermi in forma ogni giorno!'),
('sofia_v', 24, 4, '2025-01-10', 'Programmi di allenamento professionali, vale ogni centesimo speso.'),
('andrea_f', 5,  4, '2024-08-23', 'Notizie aggiornate in tempo reale, ben organizzata e molto veloce.'),
('andrea_f', 21, 3, '2025-02-25', 'Buon editor ma ci sono alternative gratuite quasi allo stesso livello.'),
('elena_c', 1,  3, '2024-07-20', 'Carina ma occupa troppa memoria sul telefono, da ottimizzare.'),
('elena_c', 36, 4, '2025-03-05', 'Suite completa per ufficio, funziona molto bene anche su mobile.'),
('davide_p', 3,  4, '2024-06-30', 'Quiz divertenti, perfetto per passare il tempo in metropolitana.'),
('davide_p', 31, 5, '2025-01-20', 'Indispensabile per organizzare i viaggi, mappe offline ottime!'),
('chiara_l', 6,  4, '2024-08-10', 'Bella app per scoprire nuova musica e artisti emergenti italiani.'),
('chiara_l', 23, 2, '2025-02-10', 'Troppi bug e si blocca spesso durante il gioco, da correggere subito.'),
('matteo_g', 7,  5, '2024-07-15', 'La migliore app per chattare con gli amici, veloce e sicura!'),
('matteo_g', 34, 3, '2025-01-30', 'Piani alimentari basilari, servirebbero opzioni piu personalizzate.'),
('sara_t', 2,  3, '2024-08-25', 'Funziona bene ma le notifiche sono troppo frequenti e invasive.'),
('sara_t', 30, 4, '2025-03-20', 'Ottima per gestire le finanze personali con grafici chiari e utili.'),
('alessandro_n', 1,  5, '2024-06-15', 'Filtri fotografici eccezionali, risultati quasi da professionista!'),
('alessandro_n', 16, 4, '2024-09-05', 'Esercizi ben spiegati, ideale per allenarsi a casa senza attrezzi.'),
('francesca_d', 3,  2, '2024-07-27', 'Si blocca troppo spesso, necessita di aggiornamenti urgenti.'),
('francesca_d', 19, 4, '2024-10-12', 'Effetti artistici unici per le foto, molto creativa e originale.'),
('giuseppe_z', 5,  5, '2024-08-17', 'Fonte di notizie affidabile, veloce e sempre aggiornata al minuto.'),
('giuseppe_z', 18, 3, '2024-11-10', 'Ricette buone ma mancano quelle della tradizione regionale italiana.'),
('valentina_s', 7,  4, '2024-07-05', 'Intuitiva e facile da usare per comunicare con amici e familiari.'),
('valentina_s', 32, 5, '2025-02-15', 'Contenuti didattici eccellenti, perfetta per studiare seriamente!'),
('roberto_a', 9,  3, '2024-07-23', 'Contenuti divertenti ma troppa pubblicita tra un video e un altro.'),
('roberto_a', 40, 4, '2025-03-17', 'Avventura coinvolgente con grafica stupenda e una bella storia.'),
('martina_e', 2,  5, '2024-09-02', 'Previsioni sempre precise, la migliore app meteo in assoluto!'),
('simone_o', 4,  4, '2024-07-13', 'Tracker fitness completo e molto motivante per ogni obiettivo.'),
('simone_o', 22, 4, '2025-02-23', 'Organizza bene i progetti lavorativi, interfaccia molto pulita.'),
('laura_i', 6,  5, '2024-08-20', 'Playlist automatiche perfette per i miei gusti musicali!'),
('laura_i', 25, 3, '2025-01-27', 'Buona app musicale ma il prezzo risulta elevato per le funzioni.'),
('fabio_u', 11, 4, '2024-07-30', 'Mappe dettagliate e precise, utilissima per viaggiare all''estero.'),
('fabio_u', 24, 5, '2025-02-27', 'Trasformazione fisica incredibile grazie a questa app straordinaria!'),
('anna_r', 10, 4, '2024-08-13', 'Calcolo spese semplice e veloce, ottima per il bilancio familiare.'),
('anna_r', 33, 3, '2025-03-10', 'Strategia interessante ma la curva di apprendimento risulta ripida.'),
('giovanni_b', 1,  4, '2024-06-23', 'Belle funzioni di editing fotografico, facile e intuitiva da usare.'),
('giovanni_b', 31, 5, '2025-01-13', 'Pianificazione viaggi perfetta con suggerimenti personalizzati!'),
('alice_m', 2,  4, '2024-07-19', 'Widget meteo molto comodo sulla schermata principale del telefono.'),
('alice_m', 32, 4, '2025-02-17', 'Ottima per studiare, contenuti ben strutturati e sempre aggiornati.'),
('lorenzo_v', 3,  5, '2024-08-27', 'Quiz sempre nuovi e stimolanti, non ci si annoia davvero mai!'),
('federica_f', 4,  4, '2024-07-03', 'Monitora bene passi e calorie giornaliere con grande precisione.'),
('federica_f', 34, 5, '2025-01-17', 'Piani alimentari personalizzati davvero funzionali ed efficaci.'),
('nicola_c', 5,  3, '2024-08-04', 'Troppe notifiche push, risulta un po'' invadente nella privacy.'),
('nicola_c', 21, 4, '2025-02-13', 'Editor foto professionale con strumenti avanzati e molto precisi.'),
('elisa_p', 6,  4, '2024-09-04', 'Scopro sempre artisti nuovi, algoritmo musicale molto azzeccato.'),
('elisa_p', 35, 4, '2025-03-23', 'Podcast di qualita con una buona selezione di contenuti italiani.'),
('daniele_l', 8,  5, '2024-07-17', 'Perfetta per prendere appunti veloci al volo durante le riunioni.'),
('daniele_l', 27, 4, '2025-01-23', 'Cloud affidabile e veloce, sincronizzazione tra dispositivi ottima.'),
('claudia_g', 9,  4, '2024-08-07', 'Video divertenti e contenuti originali per ogni momento della giornata.'),
('claudia_g', 33, 2, '2025-03-05', 'Troppo complicata per i principianti, manca un buon tutorial iniziale.'),
('stefano_t', 10, 3, '2024-06-27', 'Utile per i conti ma manca il supporto per la gestione multi-valuta.'),
('stefano_t', 30, 4, '2025-02-02', 'Gestione finanziaria completa con report mensili dettagliati e chiari.'),
('paolo_d', 6,  3, '2024-07-25', 'Funziona ma ogni tanto si blocca la riproduzione dei brani musicali.'),
('maria_z', 7,  5, '2024-08-30', 'Chat veloce e sicura, perfetta per lavoro e comunicazioni personali.'),
('emanuele_s', 8, 4, '2024-06-20', 'Sincronizzazione perfetta tra tutti i dispositivi collegati al cloud.'),
('antonio_e', 10, 4, '2024-08-23', 'Gestione delle spese chiara, intuitiva e molto ben organizzata.');

--Query:
--1)Visionare lo storico completo dei download ordinati per data effettuati da uno specifico utente in input (ad es. ‘marco_92’) per ogni suo dispositivo
SELECT A.Nome as nomeApplicazione, Di.marca, di.modello as Dispositivo, A.dimensione AS Dimensione_MB, d.data_ora as Orario_Download
FROM Applicazione A JOIN Download D ON A.id_app = D.applicazione
JOIN Dispositivo Di ON Di.imei= D.dispositivo
WHERE D.utente='marco_92' 
ORDER BY D.data_ora DESC;
--2)Elencare gli sviluppatori specificando anche la loro nazione di residenza fiscale e i loro guadagni medi da ogni app pubblicata premium

CREATE VIEW Guadagni_APP(id_sv, id_app, totale) as
SELECT sviluppatore, id_app, SUM(T.importo)
FROM Applicazione A JOIN Transazione T ON A.id_app=T.applicazione
GROUP BY A.sviluppatore, A.id_app;

CREATE VIEW Media_sviluppatore(id_sviluppatore, media) AS
SELECT id_sv, ROUND(AVG(totale),2)
FROM Guadagni_APP
GROUP BY id_sv;
 
SELECT DISTINCT S.Nome, PF.nazione, M.media AS Guadagno_Medio 
FROM Profilo_fiscale PF JOIN Sviluppatore S ON PF.partita_iva=S.fiscalita
JOIN Media_sviluppatore M ON S.id_sviluppatore=M.id_sviluppatore
ORDER BY M.media desc;

--3)Per ogni Categoria elencare il numero di applicazioni, il numero totale di download delle applicazioni appartenenti e il ricavo medio dalle Premium
CREATE VIEW Ricavi_Per_App(applicazione, ricavo) AS
SELECT Applicazione, SUM(Importo)
FROM Transazione
GROUP BY Applicazione;

SELECT cl.categoria AS Categoria, COUNT(a.ID_App) AS Numero_App, SUM(a.Num_Download) AS Download_Totali, ROUND(AVG(r.Ricavo), 2) AS Ricavo_Medio_Per_App
FROM Classificazione cl JOIN Applicazione a ON cl.Applicazione = a.ID_App
LEFT JOIN Ricavi_Per_App r ON a.ID_App = r.Applicazione
GROUP BY cl.categoria
ORDER BY Download_Totali DESC;

--4)Trovare la "Top X"(nello specifico esempio 5) delle applicazioni più “apprezzate” e recensite nello store. 
--Più nello specifico: le applicazioni che hanno ricevuto almeno N (nello esempio specifico N=1) recensioni, ordinate per voto medio decrescente e, a parità di voto, per numero di recensioni

SELECT Nome AS Nome_app, COUNT(*) AS num_recensioni, ROUND(AVG(voto),2) AS voto_medio
FROM Applicazione A JOIN Recensione  R ON A.id_app=R.applicazione
GROUP BY A.id_app
HAVING COUNT(*)>=1
ORDER BY voto_medio DESC, COUNT(*) DESC
Limit 5;

--5)Per ciascuna Piattaforma calcola il numero di applicazioni compatibili, i dispositivi registrati e il volume totale di download
CREATE VIEW App_Per_Piattaforma(piattaforma, num_app) AS
SELECT Piattaforma, COUNT(*)
FROM Compatibilita
GROUP BY Piattaforma;

CREATE VIEW Dispositivi_Download(piattaforma, num_dispositivi, num_download) AS
SELECT d.Piattaforma, COUNT(DISTINCT d.IMEI), COUNT(dl.Data_Ora)
FROM Dispositivo d
LEFT JOIN Download dl ON d.IMEI = dl.Dispositivo
GROUP BY d.Piattaforma;

SELECT p.Nome AS Piattaforma, p.Produttore, ap.Num_App AS App_Compatibili, dd.Num_Dispositivi AS Dispositivi_Registrati, dd.Num_Download AS Download_Totali
FROM Piattaforma p
JOIN App_Per_Piattaforma ap ON p.Nome = ap.Piattaforma
JOIN Dispositivi_Download dd ON p.Nome = dd.Piattaforma
ORDER BY Download_Totali DESC;
--Indici
CREATE INDEX idx_download_utente_data ON Download(Utente, Data_ora);
CREATE INDEX idx_transazione_app ON Transazione(Applicazione);
CREATE INDEX idx_recensione ON Recensione USING HASH(Applicazione);
CREATE INDEX idx_download_dispositivo ON Download(Dispositivo);
