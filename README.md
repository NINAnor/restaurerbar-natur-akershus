# Kunnskapsløft om restaurerbar natur

Akershus fylkeskommune har i samarbeid med noen kommuner satt et mål om å øke kunnskapen om restaurerbar natur i fylket. Prosjektet «Kunnskapsløft om restaurerbar natur» har som formål å kartlegge restaurerbar natur, samt prioritere noen områder for restaurering. Kartleggingen legger grunnlaget for at kommuner, frivillige organisasjoner og barn og unge kan gå i gang med restaureringstiltak.

For hver kommune er formålet å utvikle digitale kartgrunnlag som viser natur med restaureringspotensial. Prosjektet utnytter eksisterende kart for å gi en oversikt over restaurerbar natur i Akershus og, så langt det går med de kartdataene som er tilgjengelige, identifisere graden av forringelse og restaureringspotensial.

Dette repoet inneholder R-skriptene (Quarto) for andre del av prosjektet (2026), som er ledet av Norsk institutt for naturforskning (NINA). Metodene er beskrevet nærmere i NINA-rapportene til hver kommune, se for eksempel Mienna et al. (2026). Metodikken bygger på arbeidet i Nordre Follo (Skrindo et al. 2023) og første del av prosjektet (for eksempel Skrindo et al. 2025).

## Kriteriekart

Kriteriekartene viser ulike typer forringet natur i Akershus som har potensial for å restaureres.

| Kriteriekart | Skript |
|---|---|
| Grøfter i myr og skog | `Kriteriekart/grofter_myr_skog.qmd` |
| Eldre barskog med forbedringspotensial | `Kriteriekart/eldre_barskog.qmd` |
| Edelløvskog med forbedringspotensial | `Kriteriekart/edellauvskog.qmd` |
| Osp i barskog | `Kriteriekart/osp_i_barskog.qmd` |
| Kantsoner mellom vei og natur | `Kriteriekart/kantsoner_vei_natur.qmd` |
| Kantsoner uten vegetasjon langs vassdrag i lavlandet | `Kriteriekart/kantsoner_vassdrag.qmd` |
| Kantsoner langs åker | `Kriteriekart/kantsoner_aker.qmd` |
| Bekkeåpninger | `Kriteriekart/bekkeapninger.qmd` |
| Gårdsdammer og naturlige dammer | `Kriteriekart/dammer.qmd` |
| Åkerholmer med forbedringspotensial | `Kriteriekart/akerholmer.qmd` |
| Hule og store eiker i gjengroing | `Kriteriekart/hule_store_eiker.qmd` |
| Andre kartlagte naturtyper med forbedringspotensial | `Kriteriekart/kartlagte_naturtyper.qmd` |
| Grå arealer ute av bruk | `Kriteriekart/restaurerbar_graa_areal.qmd` |

## Mappestruktur

| Mappe | Innhold |
|---|---|
| `Kartgrunnlag/` | Klargjøring av inndata som brukes av flere kriteriekart (artsobservasjoner, HB13-faktaark, hogstflater og nabolagsanalyse for fremmede arter), og kart til prioritering (naturtiltak og skoler). |
| `Kriteriekart/` | Ett skript per kriteriekart. Resultatene skrives til `2026/Kriteriekart/` på prosjektområdet. |

## Rekkefølge for å kjøre skriptene

Flere skript bruker resultater fra andre skript. Kjør dem i denne rekkefølgen:

1. **Kartgrunnlag**
   - `Kartgrunnlag/artsobservasjoner.qmd` lager artsobservasjonene (`artsobs_*.csv`) som brukes i nesten alle kriteriekart.
   - `Kartgrunnlag/HB13.qmd` lager `HB13_faktaark.gpkg`, som er HB13-naturtypene med informasjon fra faktaarkene.
   - `Kartgrunnlag/hogstflater.qmd` lager `hogst_satellitt_32.tif` og `hogst_satellitt_33.tif`.
   - `Kartgrunnlag/neighborhood_analysis_invasive.qmd` lager `invasive_neighborhood.tif` (antall observasjoner av fremmede arter innenfor 100 m) fra artsobservasjonene. Den brukes i kantsoner mellom vei og natur og kantsoner langs åker.
2. **Første del av `Kriteriekart/kartlagte_naturtyper.qmd`**, til og med eksporten av `HB13_forbedringspotensial.gpkg`. Denne fila brukes av skriptene for edelløvskog og eldre barskog.
3. **De andre skriptene i `Kriteriekart/`**, i valgfri rekkefølge.
4. **Resten av `Kriteriekart/kartlagte_naturtyper.qmd`**. Denne delen leser alle de andre kriteriekartene for å fjerne naturtyper som allerede er med i et annet kriteriekart.

`Kartgrunnlag/naturtiltak.qmd` og `Kartgrunnlag/skoler.qmd` lager kart til prioritering og kan kjøres uavhengig av kriteriekartene.

## Krav for å kjøre skriptene

- **R-pakker:** arrow, DBI, dplyr, duckdb, glue, igraph, lwgeom, mapview, NinaR, nngeo, purrr, readr, readxl, rgrass, sf, stringr, terra, tidyr og tidyverse. NinaR er NINAs interne pakke og brukes til å koble til GRASS.
- **GRASS GIS** med rgrass, for `kantsoner_aker.qmd` og `neighborhood_analysis_invasive.qmd`. Skriptene kobler til NINAs GRASS-oppsett med `NinaR::grassConnect()`.
- **Tilgang til NINAs servere.** Alle filstier er skrevet fullt ut og peker til prosjektområdet (`/data/P-Prosjekter2/155014_restaurerbar_natur_akershus/`), NINAs felles kartdata (`/data/R/GeoSpatialData/`) og NINAs interne datalager (S3). Utenfor NINA må stiene endres og dataene lastes ned på nytt fra kildene under.
- **Midlertidig mappe.** De fleste skriptene skriver først til en midlertidig mappe (`/data/scratch/tmp_ida/gpkg/`) og kopierer deretter til prosjektområdet, fordi det er ustabilt å skrive GeoPackage direkte til nettverksdisken. Andre brukere må endre denne stien.

## Datakilder

Data som er lastet ned eller laget i prosjektet, ligger under `2026/Data/` på prosjektområdet. Data fra NINAs felles kartdata ligger under `/data/R/GeoSpatialData/`. Tilgang er «åpen» hvis ikke annet er oppgitt.

| Data | Dataeier og kilde | Brukes i |
|---|---|---|
| Artsobservasjoner (karplanter, sopp, lav og moser fra og med 2000) | Artsdatabanken (Artskart) | Kartgrunnlag/artsobservasjoner og de fleste kriteriekart |
| Fremmede karplanter med økologisk effekt | Artsdatabanken (Fremmedartsbasen 2023). Begrenset tilgang. | Kartgrunnlag/artsobservasjoner |
| Artslister over indikatorarter for eldre barskog, osp, edelløvskog og enger | NINA. Listene står i vedlegget til NINA-rapportene. | Kartgrunnlag/artsobservasjoner |
| Artslister over indikatorarter for eik | Sverdrup-Thygeson et al. (2010) og Dahlberg & Stokland (2004) | hule_store_eiker |
| Kartlagte naturtyper etter HB13 og MI, utvalgte naturtyper og naturtyper med KU-verdi | Miljødirektoratet (Naturbase) | Kartgrunnlag/HB13 og de fleste kriteriekart |
| Faktaark for HB13-lokaliteter | Miljødirektoratet (Naturbase) | Kartgrunnlag/HB13 |
| Koder og navn for HB13-naturtyper (`HB13_koder.xlsx`) | Hentet fra DN-håndbok 13 (Direktoratet for naturforvaltning 2007) | kartlagte_naturtyper |
| Naturtiltak | Miljødirektoratet (tiltak fra tilskuddsordningene, hentes direkte fra kartjenesten) | Kartgrunnlag/naturtiltak |
| Myrrestaurering | Statsforvalteren. Begrenset tilgang. | Kartgrunnlag/naturtiltak |
| Fjellområder | Miljødirektoratet (modellert fjellareal) | kantsoner_vassdrag |
| FKB-Vann | Kartverket | kantsoner_vassdrag, bekkeapninger |
| N50 (veier) | Kartverket | kantsoner_vei_natur |
| Høydedata (DTM10 og strømningsakkumulering) | Kartverket | akerholmer |
| Trehøydemodell (vegetasjon over eller under 2 m) | Laget fra høydedata (Kartverket) i Google Earth Engine, se lenke i `kantsoner_vassdrag.qmd` | kantsoner_vassdrag, kantsoner_vei_natur |
| Fylkes- og kommunegrenser | Kartverket | flere skript |
| SR16 V treslag | NIBIO | edellauvskog, eldre_barskog, osp_i_barskog |
| SR16-beta bestandsalder | NIBIO | edellauvskog |
| Naturskogsnærhet og hogstflater | NIBIO (naturskogkartet) | Kartgrunnlag/hogstflater, eldre_barskog |
| Grå arealer | NIBIO | de fleste kriteriekart, restaurerbar_graa_areal, bekkeapninger |
| AR5 (arealressurskart) | NIBIO. Begrenset tilgang (krever Norge digitalt-bruker). | akerholmer, grofter_myr_skog, hule_store_eiker, kantsoner, bekkeapninger |
| Jordkvalitet | NIBIO | kantsoner_aker |
| Grøftekart (KI-modellerte grøfter) | NINA (Jansson et al. 2024). Begrenset tilgang, kontakt forfatterne. | grofter_myr_skog |
| Pollinatorhabitat | NINA (Sydenham et al. 2023) | kantsoner_vei_natur, kantsoner_aker |
| Gårdsdammer og naturlige dammer | NINA. Bygger på NINAs prediksjonsmodell for gårdsdammer (Bakkestuen et al. 2025), med flybildetolking og klassifisering av ekspert. | dammer |
| Skoler (grunnskoler og videregående skoler) | Geonorge | Kartgrunnlag/skoler |

## Utdata

- `2026/Kriteriekart/`: én GeoPackage per kriteriekart for hele Akershus.
- `2026/Tilleggsdata/`: kart til prioritering.

## Referanser

- Bakkestuen, V., Dervo, B.K., Erikstad, L., Gregersen, F., Mjelde, M., Pettersen, R., Schartau, A.K. & Velle, G. 2025. Modellering av limniske naturtyper og metode for beregning av påvirkning i ferskvann og brakkvann. NINA Rapport 2595. Norsk institutt for naturforskning.
- Dahlberg, A. & Stokland, J. 2004. Vedlevande arters krav på substrat – sammanställning och analys av 3 600 arter. Skogsstyrelsen, Rapport 7-04.
- Direktoratet for naturforvaltning 2007. Kartlegging av naturtyper – verdisetting av biologisk mangfold. DN-håndbok 13, 2. utgave 2006 (oppdatert 2007).
- Mienna, I.M. et al. 2026. Kunnskapsløft om restaurerbar natur. Med en beskrivelse av ti mulige restaureringsprosjekter i Nes kommune. NINA Rapport 2813. Norsk institutt for naturforskning. https://hdl.handle.net/11250/5585200
- Jansson, U., Bakkestuen, V., Lyngstad, A. & Mienna, I.M. 2024. Utvikling av grøftekart i myr og torvmark i Norge med hjelp av dyplæring. NINA Rapport 2443. Norsk institutt for naturforskning.
- Skrindo, A.B., Simensen, T., Jansson, U., Bakkestuen, V., Dervo, B., Hagen, D., Mehlhoop, A.C., Museth, J. & Singsaas, F.T. 2023. Restaurerbar natur Nordre Follo. NINA Rapport 2314. Norsk institutt for naturforskning.
- Skrindo, A.B. et al. 2025. Kunnskapsløft om restaurerbar natur. Med en beskrivelse av ti mulige restaureringsprosjekter i Lillestrøm kommune. NINA Rapport 2661. Norsk institutt for naturforskning. https://hdl.handle.net/11250/5333881
- Sverdrup-Thygeson, A., Bratli, H., Brandrud, T.E. & Ødegaard, F. 2010. Faglig grunnlag for handlingsplan for hule eiker. NINA Rapport 631.
- Sydenham, M.A.K., Venter, Z., Eldegard, K. et al. 2023. The contributions of flower strips to wild bee conservation in agricultural landscapes can be predicted using pollinator habitat suitability models [datasett]. Dryad. https://doi.org/10.5061/dryad.280gb5mvp

## Kontakt

- Prosjektleder: Astrid B. Skrindo (astrid.skrindo@nina.no)
- GIS-ansvarlig: Ida Marielle Mienna (ida.mienna@nina.no)

Skriptene er skrevet av Ida Marielle Mienna og Jenny Hansen.
