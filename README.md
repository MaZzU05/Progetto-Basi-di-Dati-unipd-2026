# AppHub — Progetto di Basi di Dati UniPd Anno Accademico 2025/2026

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![C](https://img.shields.io/badge/Language-C-A8B9CC?logo=c&logoColor=white)](https://en.wikipedia.org/wiki/C_(programming_language))
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Progetto accademico per l'insegnamento di **Basi di Dati**  
Corso di Laurea in Informatica — **Università degli Studi di Padova** (A.A. 2025/2026).

---

## 👥 Autori

* **Francesco Mazzurana** — [GitHub](https://github.com/MaZzU05)
* **Gianmaria Grinovero** — [GitHub](https://github.com/giangrinovero)

---

## 📖 Descrizione del Progetto

**AppHub** è un sistema informativo dedicato alla gestione di uno store digitale per applicazioni mobili. Il database centralizza il catalogo delle app e gestisce le relazioni tra sviluppatori e utenti finali.

### Caratteristiche principali:
* **Catalogo Applicazioni:** Suddivisione tra applicazioni gratuite (con advertising) e premium (con prezzo e periodo di prova).
* **Entità e Relazioni:** Gestione di profili fiscali degli sviluppatori, compatibilità multi-piattaforma (Android, iOS, Windows, HarmonyOS), dispositivi fisici (IMEI), download e recensioni con voti.
* **Progettazione Logica & Performance:**
  * Mantenimento controllato della ridondanza per il conteggio dei download a seguito dell'analisi dei costi di accesso.
  * Accorpamento della gerarchia delle app nell'entità genitore tramite tipo enumerativo.
  * Creazione di indici dedicati (B-Tree compositi e Hash) per l'ottimizzazione delle query analitiche e dei filtri temporali.

---

## 📂 Struttura della Repository

```text
AppHub/
├── docs/
│   └── Relazione_Mazzurana_Grinovero.pdf   # Documentazione e schemi E-R
├── sql/
│   └── appHub.sql                          # Script DDL, dati di test, viste e indici
├── src/
│   ├──AppHub.c                            # Client interattivo da terminale in C
│   └── dependencies/                      # Header e librerie libpq per macOS
│       ├── include/
│       └── lib/
└── README.md
```
---

## 🏛️ Caratteristiche del Progetto

* **Modellazione Concettuale e Logica:**
  * Gestione di entità forti e deboli (Download, Recensioni) con vincoli di integrità referenziale.
  * Analisi formale costi/accessi per la ridondanza dell'attributo `Num_Download`.
  * Accorpamento della gerarchia delle applicazioni verso la tabella padre tramite tipo enumerativo (`Gratuita`, `Premium`).
* **Ottimizzazione PostgreSQL:**
  * Viste analitiche per metriche di business (ricavi, guadagni medi per sviluppatore, riepilogo categorie).
  * Indici mirati: indici B-Tree su chiavi esterne per accelerare Join/Group By, indice B-Tree composito `Download(Utente, Data_Ora)` e indice HASH su `Recensione(Applicazione)`.
* **Client C con `libpq`:**
  * Dashboard interattiva da terminale con supporto a colori ANSI.
  * Query parametriche sicure gestite tramite `PQexecParams`.
  * Formattazione dinamica e allineamento automatico dell'output a tabella.

---

## 🚀 Guida all'Installazione e Uso

### 1. Prerequisiti
* **PostgreSQL** installato e in esecuzione.
* Compilatore `gcc` o `clang`.

### 2. Configurazione Database
Accedere al terminale ed eseguire lo script unico di configurazione (crea lo schema, popola i dati, crea le viste e gli indici):

```bash
# Creazione del database
createdb apphub_db

# Esecuzione script
psql -d apphub_db -f sql/appHub.sql
```

### 3. Compilazione del Client C (macOS)
Il repository include la cartella `dependencies/` con gli header e i binari della libreria `libpq`. Per compilare il codice è sufficiente eseguire:

```bash
gcc src/AppHub.c -I dependencies/include -L dependencies/lib -lpq -o apphub
```

*(Nota per Linux: se compilate su sistemi GNU/Linux con `libpq` di sistema, è sufficiente `gcc src/AppHub.c -lpq -o apphub`)*.

### 4. Esecuzione
Avviare il programma da terminale:

```bash
./apphub
```

Al primo avvio comparirà una schermata di riepilogo parametri (Host, Porta, Nome DB, User, Password):
1. Inserire i propri parametri locali di PostgreSQL o premere `-1` per procedere alla connessione.
2. Dal menu principale scegliere l'operazione desiderata:
   * **[1]** Storico download per utente parametrico (es. `marco_92`).
   * **[2]** Guadagni medi da app premium per sviluppatore e nazione.
   * **[3]** Statistiche per categoria (volume app, download, ricavo medio).
   * **[4]** Classifica Top X delle migliori app con filtro su numero minimo di recensioni.
   * **[5]** Statistiche per piattaforma (applicazioni compatibili, dispositivi, download).

---

## 📄 Note di Distribuzione

Il materiale è rilasciato con licenza libera per scopi accademici e di consultazione.
