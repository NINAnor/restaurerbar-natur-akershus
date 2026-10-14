# Kunnskapsløft om restaurerbar natur

Akershus fylkeskommune har i samarbeid med noen kommuner satt et mål om å øke kunnskapen om restaurerbar natur i fylket. Prosjektet «Kunnskapsløft om restaurerbar natur» har som formål å kartlegge restaurerbar natur, samt prioritere noen områder for restaurering. Kartleggingen legger grunnlaget for at kommuner, frivillige organisasjoner og barn og unge kan gå i gang med restaureringstiltak.

For hver kommune er formålet å utvikle digitale kartgrunnlag som viser natur med restaureringspotensial. Prosjektet utnytter eksisterende kart for å gi en oversikt over restaurerbar natur i Akershus og, så langt det går med de kartdataene som er tilgjengelige, identifisere graden av forringelse og restaureringspotensial.

Dette repoet inneholder R-skriptene (Quarto) for andre del av prosjektet (2026), som er ledet av Norsk institutt for naturforskning (NINA).

## Kriteriekart

Kriteriekartene viser ulike typer forringet natur i Akershus som har potensial for å restaureres. Tabellen viser kriteriekartene, skriptet som lager dem, og om de er med i leveransene til kommunene.

| Kriteriekart | Skript | Med i leveransen |
|---|---|---|
| Grøfter i myr og skog | `Kriteriekart/grofter_myr_skog.qmd` | Ja |
| Eldre barskog med forbedringspotensial | `Kriteriekart/eldre_barskog.qmd` | Ja |
| Edelløvskog med forbedringspotensial | `Kriteriekart/edellauvskog.qmd` | Ja |
| Osp i barskog | `Kriteriekart/osp_i_barskog.qmd` | Ja |
| Kantsoner uten vegetasjon langs vassdrag i lavlandet | `Kriteriekart/kantsoner_vassdrag_ida.qmd` | Ja |
| Kantsoner langs åker | `Kriteriekart/kantsoner_aker_ida.qmd` | Ja |
| Gårdsdammer og naturlige dammer | `Kriteriekart/dammer.qmd` | Ja |
| Åkerholmer med forbedringspotensial | `Kriteriekart/akerholmer.qmd` | Ja |
| Hule og store eiker i gjengroing | `Kriteriekart/hule_store_eiker.qmd` | Ja |
| Andre kartlagte naturtyper med forbedringspotensial | `Kriteriekart/kartlagte_naturtyper.qmd` | Ja |
| Kantsoner mellom vei og natur | `Kriteriekart/kantsoner_vei_natur_ida.qmd` | Nei |
| Grå arealer ute av bruk | `Kriteriekart/restaurerbar_graa_areal_ida.qmd` | Nei |

## Mappestruktur

| Mappe | Innhold |
|---|---|
| `Kartgrunnlag/` | Klargjøring av inndata som brukes av flere kriteriekart (artsobservasjoner, HB13-faktaark, hogstflater), og tilleggsdata til kommunene (kommunedata, naturtiltak, skoler). |
| `Kriteriekart/` | Ett skript per kriteriekart. Resultatene skrives til `2026/Kriteriekart/` på prosjektområdet. |
| `Resultater/` | Leveranser til kommunene (`leveranse_kommuner.qmd`, `readme_kommuner.qmd`) og oppsummerende statistikk. |
| `Validering/` | Vask av feltdata og validering av kriteriekartene mot feltobservasjoner fra 2025 og 2026. |

## Rekkefølge for å kjøre skriptene

Flere skript bruker resultater fra andre skript. Kjør dem i denne rekkefølgen:

1. **Kartgrunnlag**
   - `Kartgrunnlag/artsobservasjoner.qmd` lager artsobservasjonene (`artsobs_*.csv`) som brukes i nesten alle kriteriekart.
   - `Kartgrunnlag/HB13.qmd` lager `HB13_faktaark.gpkg`, som er HB13-naturtypene med informasjon fra faktaarkene.
   - `Kartgrunnlag/hogstflater.qmd` lager `hogst_satellitt_32.tif` og `hogst_satellitt_33.tif`.
2. **Første del av `Kriteriekart/kartlagte_naturtyper.qmd`**, til og med eksporten av `HB13_forbedringspotensial.gpkg`. Denne fila brukes av skriptene for edelløvskog og eldre barskog. Skriptet for hule eiker leser den også, men bruker den ikke.
3. **De andre skriptene i `Kriteriekart/`**, i valgfri rekkefølge.
4. **Resten av `Kriteriekart/kartlagte_naturtyper.qmd`**. Denne delen leser alle de andre kriteriekartene for å fjerne naturtyper som allerede er med i et annet kriteriekart.
5. **`Resultater/leveranse_kommuner.qmd`** klipper kriteriekartene mot kommunegrensene og skriver to filgeodatabaser til hver kommunemappe under `2026/Leveranser/`: én med kriteriekartene og én med prioriteringskartene.
6. **`Resultater/readme_kommuner.qmd`** lager en README per kommune fra `2026/Leveranser/README_master.docx`.

Skriptene i `Validering/` og de andre skriptene i `Kartgrunnlag/` kan kjøres uavhengig av kriteriekartene.

## Krav for å kjøre skriptene

- **R-pakker:** arrow, broom, DBI, dplyr, duckdb, ggplot2, glue, igraph, lwgeom, mapview, NinaR, nngeo, officer, openxlsx, purrr, readr, readxl, rgrass, scales, sf, stringr, terra, tibble, tidyr og writexl. NinaR er NINAs interne pakke og brukes til farger i figurene i `Validering/` og til å koble til GRASS.
- **GRASS GIS** med rgrass, for `kantsoner_aker_ida.qmd`. Skriptet kobler til NINAs GRASS-oppsett med `NinaR::grassConnect()`.
- **GDAL 3.6 eller nyere**, for å skrive filgeodatabaser i `leveranse_kommuner.qmd`.
- **Tilgang til NINAs servere.** Alle filstier er skrevet fullt ut og peker til prosjektområdet (`/data/P-Prosjekter2/155014_restaurerbar_natur_akershus/`), NINAs felles kartdata (`/data/R/GeoSpatialData/`) og NINAs interne datalager (S3). Utenfor NINA må stiene endres og dataene lastes ned på nytt fra kildene under.
- **Midlertidig mappe.** De fleste skriptene skriver først til `~/Mounts/scratch/tmp_ida/gpkg/` og kopierer deretter til prosjektområdet, fordi det er ustabilt å skrive GeoPackage direkte til nettverksdisken. Andre brukere må endre denne stien.

## Datakilder

Data som er lastet ned eller laget i prosjektet, ligger under `2026/Data/` på prosjektområdet. Data fra NINAs felles kartdata ligger under `/data/R/GeoSpatialData/`.

| Data | Kilde | Brukes i |
|---|---|---|
| Kartlagte naturtyper etter HB13 og MI, utvalgte naturtyper og KU-verdi | Naturbase, Miljødirektoratet. Lastet ned 27.02.2026. | Kartgrunnlag/HB13 og de fleste kriteriekart |
| Faktaark for HB13-lokaliteter | Hentet fra faktaarkene i Naturbase av NINA og lagret i NINAs interne datalager (S3) | Kartgrunnlag/HB13 |
| Koder og navn for HB13-naturtyper (`HB13_koder.xlsx`) | [Fyll inn kilde] | kartlagte_naturtyper |
| Naturtiltak | Naturbase, Miljødirektoratet (hentes direkte fra kartjenesten) | Kartgrunnlag/naturtiltak |
| Myrrestaurering (demninger, grøfter, prosjekter og torvtak) | [Fyll inn kilde] | Kartgrunnlag/naturtiltak |
| Artsobservasjoner (karplanter, sopp, lav og moser fra og med 2000) | Artskart, Artsdatabanken. Lastet ned 27.02.2026. | Kartgrunnlag/artsobservasjoner |
| Fremmede karplanter med økologisk effekt | Fremmedartslista 2023, Artsdatabanken | Kartgrunnlag/artsobservasjoner |
| Indikatorarter for skog (`Artslister_indikatorer_skog.xlsx`) | [Fyll inn kilde] | Kartgrunnlag/artsobservasjoner |
| Engarter, artsliste for eik (Anne Sverdrup-Thygeson 2010) og vedlevende biller (DödBasen) | Fra 2025-delen av prosjektet. [Fyll inn kilder] | Kartgrunnlag/artsobservasjoner, hule_store_eiker |
| AR5 (arealressurskart) | FKB-AR5, NIBIO | akerholmer, grofter_myr_skog, hule_store_eiker, kantsoner |
| SR16 (skogressurskart) | NIBIO | edellauvskog, eldre_barskog, osp_i_barskog |
| Naturskogsnærhet og hogstflater fra satellitt | Naturskogkartet versjon 1. [Fyll inn kilde] | Kartgrunnlag/hogstflater, eldre_barskog |
| Grå arealer | Kart over grå arealer versjon 1. [Fyll inn kilde] | edellauvskog, eldre_barskog, osp_i_barskog, kartlagte_naturtyper, restaurerbar_graa_areal |
| Grøfter fra KI-modell | Fra 2025-delen av prosjektet (`2025/DitchesOut/`). [Fyll inn kilde og metode] | grofter_myr_skog |
| Høydemodell (DTM10) og strømningsakkumulering | Fra 2025-delen av prosjektet (`2025/Kartlegging/Data_Akershus/dtm10.gdb`) | akerholmer |
| Gårdsdammer og naturlige dammer | [Fyll inn kilde] (`2026/Data/Dammer/`) | dammer |
| FKB-Vann | Kartverket | kantsoner_vassdrag |
| Fjellområder | Modellert fjellareal, Miljødirektoratet | kantsoner_vassdrag |
| Trehøydemodell (vegetasjon over eller under 2 m) | Laget i Google Earth Engine, se lenke i `kantsoner_vassdrag_ida.qmd` | kantsoner_vassdrag, kantsoner_vei_natur |
| Pollinatorkart og nabolag for fremmede arter (`polliland_akershus.tif`, `invasive_neighborhood.tif`) | [Fyll inn kilde] | kantsoner_vei_natur, kantsoner_aker |
| Jordkvalitet (`jordkvalitet.gpkg`) | [Fyll inn kilde] | kantsoner_aker |
| N50 (veier) | Kartverket | kantsoner_vei_natur, Validering |
| Fylkes- og kommunegrenser | Kartverket | flere skript og leveransene |
| Skoler | Kartverket (Geonorge) | Kartgrunnlag/skoler |
| SSB rutenett 1 km | Statistisk sentralbyrå | Validering |
| Feltdata 2026 | Samlet inn i felt med Survey123 (`2026/Data/Feltdata/`) | Validering |
| Data fra kommunene | Levert av Frogn, Lunner, Nesodden og Rælingen kommune | Kartgrunnlag/Kommunedata |

## Utdata

- `2026/Kriteriekart/`: én GeoPackage per kriteriekart for hele Akershus.
- `2026/Leveranser/<kommune>/`: filgeodatabaser og README for hver kommune.
- `2026/Tilleggsdata/`: tilleggsdata til kommunene og data til valideringen.

## Kontakt

- Prosjektleder: Astrid B. Skrindo (astrid.skrindo@nina.no)
- GIS-ansvarlig: Ida Marielle Mienna (ida.mienna@nina.no)

Skriptene for kantsoner langs vassdrag, kantsoner langs åker, kantsoner mellom vei og natur og grå arealer er skrevet av Jenny Hansen (NINA).
