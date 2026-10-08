#include <stdio.h>
#include<stdlib.h>
#include <string.h>
#include "dependencies/include/libpq-fe.h"

//le prime tre funzioni sono meramente legate all'estetica
// Colori ANSI per l'interfaccia reperiti qua: https://gist.github.com/RabaDabaDoba/145049536f815903c79944599c6f952a
#define RED     "\e[0;31m"
#define GREEN   "\e[0;32m"
#define YELLOW  "\e[0;33m"
#define CYAN    "\e[0;36m"
#define RESET   "\e[0m"

//ascii-art generata con https://patorjk.com/software/taag/, con font reverse
void stampa_logo()
{

    printf(YELLOW);
    printf("================================================\n");
    printf("====  ===================  ====  =========  ====\n");
    printf("===    ==================  ====  =========  ====\n");
    printf("==  ==  =================  ====  =========  ====\n");
    printf("=  ====  ==    ===    ===  ====  ==  =  ==  ====\n");
    printf("=  ====  ==  =  ==  =  ==        ==  =  ==    ==\n");
    printf("=        ==  =  ==  =  ==  ====  ==  =  ==  =  =\n");
    printf("=  ====  ==    ===    ===  ====  ==  =  ==  =  =\n");
    printf("=  ====  ==  =====  =====  ====  ==  =  ==  =  =\n");
    printf("=  ====  ==  =====  =====  ====  ===    ==    ==\n");
    printf("================================================\n\n");
    printf(RESET);//per togliere il colore dal testo successivo
}

//visualizzazione ordinata della lista delle query
void visualizza_lista_query() {
    printf("\n");
    printf("+-----------------------------------------------------------------------------------------+\n");
    printf("|" YELLOW "                                   APP HUB - MENU                                        " RESET "|\n"); //allungato per avere le barre laterali uguali
    printf("+-----------------------------------------------------------------------------------------+\n");
    printf("| [1] Storico completo download di un utente per ogni suo dispositivo                     |\n");
    printf("| [2] Sviluppatori, nazione fiscale e guadagni medi da app premium                        |\n");
    printf("| [3] Statistiche Categorie (numero app, download totali, ricavo medio premium)           |\n");
    printf("| [4] Top x App più apprezzate con almeno N recensioni (ordinate per voto medio)          |\n");
    printf("| [5] Statistiche Piattaforme (app compatibili, dispositivi e download)                   |\n");
    printf("+-----------------------------------------------------------------------------------------+\n");
    printf("| "GREEN"[0] Ristampa Menu "RESET"                      |                      "RED"[6] Esci dal Programma   "RESET"|\n");
    printf("+-----------------------------------------------------------------------------------------+\n\n");
}

// Separatore personalizzabile, disegna dinamicamente i separatori della tabella in base alla lunghezza dei dati attuali, col carattere passato al tratto si decide il tratto appunto, mentre quello passato a giuntura serve per i "punti di collegamento"
void stampa_separatore(int* larghezza_colonne, int colonne, char tratto, char giuntura) {
    for (int i = 0; i < colonne; i++) {
        for (int j = 0; j < larghezza_colonne[i] + 2; j++) {
            printf("%c", tratto);
        }
        // Stampa la giuntura
        if (i < colonne - 1) {
            printf("%c", giuntura);
        }
    }
    printf("\n");
}
void do_exit(PGconn* conn)
{
    PQfinish(conn);
    exit(1);
}

PGconn* connessione_database(const char* user, const char* password, const char* dbname, const char* hostname, const char* port)
{
    char dati_connessione[300];
    //per iniettare l'input nella forma corretta uso sprintf
    sprintf(dati_connessione, "user=%s password=%s dbname=%s hostaddr=%s port=%s", user, password, dbname, hostname, port);
    PGconn* connessione=PQconnectdb(dati_connessione);
    //se la connessione fallisce stampo in standard error il log di errore generator
    if(PQstatus(connessione)== CONNECTION_BAD)
    {
        fprintf(stderr, RED"Connessione al DB fallita: %s"RESET, PQerrorMessage(connessione));
        do_exit(connessione);
    }
    printf(GREEN"Connessione al DB avvenuta con successo\n"RESET);
    return connessione;
}

void stampa_query(PGresult* res)
{   int righe = PQntuples(res);
    int colonne = PQnfields(res);
    //creo un array dinamico che conterrà la larghezza perfetta per ogni colonna
    int* larghezza_colonne = malloc(colonne * sizeof(int)); //alloca in memoria
    for (int i = 0; i < colonne; i++) {
        //parto assumendo che la cosa più lunga sia il titolo della colonna
        larghezza_colonne[i] = strlen(PQfname(res, i));
        //ora guardo tutti i dati riga per riga deella colonna relativa al titolo attuale
        for (int j = 0; j < righe; j++) {
            int len = strlen(PQgetvalue(res, j, i));
            //Se trovo un dato più lungo del titolo (o del record precedente), aggiorno il record
            if (len > larghezza_colonne[i]) {
                larghezza_colonne[i] = len;
            }
        }
    }
    printf("\n");
    //bordo superiore
    stampa_separatore(larghezza_colonne, colonne, '=', '=');
    //parte di intestazione
    for (int i = 0; i < colonne; i++) {
        printf(YELLOW " %-*s " RESET, larghezza_colonne[i], PQfname(res, i));
        if (i < colonne - 1) printf("|"); // separatore per distinguere le colonne
    }
    printf("\n");
    //separatore tra intestazione e dati
    stampa_separatore(larghezza_colonne, colonne, '-', '+');
    //stampa i dati della tabella
    for (int i = 0; i < righe; i++) {
        for (int j = 0; j < colonne; j++) {
            printf(" %-*s ", larghezza_colonne[j], PQgetvalue(res, i, j)); //il -* serve per prendere la
            if (j < colonne - 1) printf("|"); // Separatore verticale solo in mezzo
        }
        printf("\n");
    }
    //bordo inferiore doppio come sopra
    stampa_separatore(larghezza_colonne, colonne, '=', '=');
    free(larghezza_colonne); //libero la memoria allocata
    PQclear(res);
}

//esecuzione query senza parametri
PGresult* esegui_query(PGconn* connessione, const char* query)
{
    PGresult* res= PQexec(connessione, query);
    if(PQresultStatus(res)!= PGRES_TUPLES_OK)
    {
        fprintf(stderr, "\nRisultato non restituito, errore: %s\n", PQerrorMessage(connessione));
        do_exit(connessione);
    }
    return res;
}
//esecuzione della query con parametro inserito da utente
PGresult* esegui_query_parametrica(PGconn* connessione, const char* query, int numero_parametri, const char* const *parametri)
{
     int paramFormat[numero_parametri];
     for(int i=0; i<numero_parametri; i++)
     {
        paramFormat[i]=0;
     }
     PGresult* res=PQexecParams(connessione, query, numero_parametri, NULL, parametri, paramFormat, NULL, 0);
     if(PQresultStatus(res)!= PGRES_TUPLES_OK)
    {
        fprintf(stderr, RED"\nRisultato non restituito, errore: %s\n"RESET, PQerrorMessage(connessione));
        do_exit(connessione);
    }
     return res;

}
//selezione delle query e azioni di visione lista query e uscita
PGresult* seleziona_query(PGconn* connessione)
{
    int n=0;
    while(n<=0||n>6)
    {
        printf(CYAN "\n[ AppHub ] > " RESET);
        printf("Seleziona un'opzione (0 per stampare la lista query, 1-5 per le relative query , 6 per uscire): ");
        int test;
        //controllo col ritorno di scanf se valido, il controllo dell'intervallo viene gia' fatto dal while principale
        do
        {
            test=scanf("%d", &n);
            if(test!=1)
            {
                printf(RED"Input non valido, devi inserire un numero\n"RESET);
                while(getchar()!='\n'); //serve a pulire il buffer di input
            }
        } while (test!=1);
        if(n==0)
        {
            visualizza_lista_query();
        }
        else if(n<0||n>6)
        {
            printf(RED"Input non valido, riprova\n"RESET);
            n=0;
        }
    }

    //le viste sono gia' definite nel DB, non le creo qua, sarebbe inefficente, poco sicuro e manuntenibile
    switch(n)
    {
        case 1:
        {
          const char* query="SELECT A.Nome as nomeApplicazione, Di.marca, di.modello as Dispositivo, A.dimensione AS Dimensione_MB, d.data_ora as Orario_Download "
                            "FROM Applicazione A JOIN Download D ON A.id_app = D.applicazione "
                            "JOIN Dispositivo Di ON Di.imei= D.dispositivo "
                            //"WHERE D.utente='marco_92' "
                            "WHERE D.utente= $1 "
                            "ORDER BY D.data_ora DESC; ";
           const char* parametri[1];
           int test;
           char nomeUtente[30];
           do
          {
            printf("Inserisci il nome dell'utente: ");
            test=scanf("%29s", nomeUtente);
            if(test!=1)
            {
                printf("Input non valido\n");
                while(getchar()!='\n');
            }
        } while (test!=1);
          parametri[0]=nomeUtente;
          return esegui_query_parametrica(connessione, query, 1, parametri);
          break;
    }
        case 2:
        {
          const char* query="SELECT DISTINCT S.Nome, PF.nazione, M.media AS Guadagno_Medio "
                            "FROM Profilo_fiscale PF JOIN Sviluppatore S ON PF.partita_iva=S.fiscalita "
                            "JOIN Media_sviluppatore M ON S.id_sviluppatore=M.id_sviluppatore "
                            "ORDER BY M.media desc; ";
          return esegui_query(connessione, query);
          break;
        }
        case 3:
        {
          const char* query="SELECT cl.categoria AS Categoria, COUNT(a.ID_App) AS Numero_App, SUM(a.Num_Download) AS Download_Totali, ROUND(AVG(r.Ricavo), 2) AS Ricavo_Medio_Per_App "
                            "FROM Classificazione cl JOIN Applicazione a ON cl.Applicazione = a.ID_App "
                            "LEFT JOIN Ricavi_Per_App r ON a.ID_App = r.Applicazione "
                            "GROUP BY cl.categoria "
                            "ORDER BY Download_Totali DESC; ";
          return esegui_query(connessione, query);
          break;
        }
        case 4:
        {
          const char* query="SELECT Nome AS Nome_app, COUNT(*) AS num_recensioni, ROUND(AVG(voto),2) AS voto_medio "
                            "FROM Applicazione A JOIN Recensione  R ON A.id_app=R.applicazione "
                            "GROUP BY A.id_app "
                            "HAVING COUNT(*)>= $1 "
                            "ORDER BY voto_medio DESC, COUNT(*) DESC "
                            "LIMIT $2; ";
          const char* parametri2[2];
          int test;
          int numRecensioni;
          int numRisultati;
          do
          {
            printf("Inserisci il numero minimo di recensioni: ");
            test=scanf("%d", &numRecensioni);
            if(test!=1||numRecensioni<=0)
            {
                printf("Input non valido, devi inserire un numero maggiore di 0\n");
                while(getchar()!='\n');
            }
          } while (test!=1||numRecensioni<=0);
          do
          {
            printf("Inserisci quanti risultati mostrare: ");
            test=scanf("%d", &numRisultati);
            if(test!=1||numRisultati<=0)
            {
                printf("Input non valido, devi inserire un numero maggiore di 0\n");
                while(getchar()!='\n');
            }
          } while (test!=1||numRisultati<=0);
          char numeroRecensioni[12];
          sprintf(numeroRecensioni, "%d", numRecensioni);
          char numeroRisultati[12];
          sprintf(numeroRisultati, "%d", numRisultati);
          parametri2[0]=numeroRecensioni;
          parametri2[1]=numeroRisultati;
          return esegui_query_parametrica(connessione, query, 2, parametri2);
          break;
        }
        case 5:
        {
          const char* query="SELECT p.Nome AS Piattaforma, p.Produttore, ap.Num_App AS App_Compatibili, dd.Num_Dispositivi AS Dispositivi_Registrati, dd.Num_Download AS Download_Totali "
                            "FROM Piattaforma p "
                            "JOIN App_Per_Piattaforma ap ON p.Nome = ap.Piattaforma "
                            "JOIN Dispositivi_Download dd ON p.Nome = dd.Piattaforma "
                            "ORDER BY Download_Totali DESC; ";
          return esegui_query(connessione, query);
          break;
        }
        case 6:
        {
          do_exit(connessione);
          break;
        }
        default:
        return NULL;
    }
    return NULL;

}

int main(int argc, char** argv) {
    
   stampa_logo();
    //input per connessione al DB
    printf(CYAN "=== INIZIALIZZAZIONE DATABASE ===\n" RESET);
    char user[30];
    printf("Inserisci l'user: ");
    scanf("%29s", user); //limito la lunghezza dell'input per evitare buffer overflow
    char password[30];
    printf("Inserisci la password: ");
    scanf("%29s", password);
    char nome[30];
    printf("Inserisci il nome del database: ");
    scanf("%29s", nome);
    char host[30];
    printf("Inserisci l'ip dell'host: ");
    scanf("%29s", host);
    char porta[30];
    printf("Inserisci la porta: ");
    scanf("%29s", porta);
    int n;
    int test;
    do
    {
        
        do
          {
            //mostro a schermo il menù di connessione
            printf(YELLOW "+--------------------------------------------------------------------------------+\n" RESET);
            printf(YELLOW "|" RESET CYAN " RIEPILOGO PARAMETRI DI CONNESSIONE, SELEZIONA IL RELATIVO VALORE PER MODIFICARE" RESET YELLOW "|\n" RESET);
            printf(YELLOW "+--------------------------------------------------------------------------------+\n" RESET);
            printf("| [1] User       : %-29s                                 |\n", user); //gli spazi servono per pareggiare la barra laterale
            printf("| [2] Password   : %-29s                                 |\n", password);
            printf("| [3] Nome DB    : %-29s                                 |\n", nome);
            printf("| [4] IP Host    : %-29s                                 |\n", host);
            printf("| [5] Porta      : %-29s                                 |\n", porta);
            printf(YELLOW "+--------------------------------------------------------------------------------+\n" RESET);
            printf("| " GREEN "[-1] CONNETTI AL DATABASE" RESET "                                                      |\n");
            printf(YELLOW "+--------------------------------------------------------------------------------+\n\n" RESET);
            test=scanf("%d", &n);
            if(test!=1)
            {
                printf(RED"Input non valido, devi inserire un numero\n"RESET);
                while(getchar()!='\n');
            }
          } while (test!=1);
        switch(n)
        {
            case -1:
               break;
            case 0:
               printf("Valori attualmente inseriti:\n [user]: %s\n [password]: %s\n [nome]: %s\n [host]: %s\n [porta]: %s\n", user, password, nome, host, porta);
               break;
            case 1:
               printf("User attualmente inserito: %s\nInserisci il nuovo user: ", user);
               scanf("%29s", user);
               break;
            case 2:
               printf("Password inserita: %s\nInserisci la nuova password: ", password);
               scanf("%29s", password);
               break;
            case 3:
               printf("Nome DB inserito: %s\nInserisci il nuovo nome: ", nome);
               scanf("%29s", nome);
               break;
            case 4:
               printf("IP Host inserito: %s\nInserisci il nuovo IP: ", host);
               scanf("%29s", host);
               break;
            case 5:
               printf("Porta inserita: %s\nInserisci la nuova porta: ", porta);
               scanf("%29s", porta);
               break;
            default:
               printf(RED"Valore non valido!\n"RESET);
             
        }
    } while (n!=-1);
    PGconn* connection = connessione_database(user, password, nome, host, porta);
    //faccio un while true, di volta in volta chiedo l'azione da eseguire, se e' una query chiamo la funzione di stampa(se valida), altrimenti eseguo le altre azioni
    while(1)
    {
        PGresult* res=seleziona_query(connection);
        if(res==NULL)
          {
           printf(RED"Errore nella query\n"RESET);
          }
        else
         {
          printf(GREEN"Query eseguita con successo!\n"RESET);
          stampa_query(res);
          //svuoto il buffer di input da eventuali caratteri speciali rimasti, es /n
          int c;
          while ((c = getchar()) != '\n' && c != EOF);
          // Pausa prima di tornare al menu, apsetto che l'utente digiti invio
          printf("\nPremi INVIO per continuare...\n");
          getchar(); // Cattura l'invio
         }
    }
    PQfinish(connection);
    return 0;
}

