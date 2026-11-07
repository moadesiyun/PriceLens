# PriceLens — Spec

## Problem

*The American Healthcare industry is a trillon dollars, yet the patients seem to pay the most for least beenefit. People need more transparency into the cost for their hospital visits.

## Users

_2–3 types of user, e.g. a revenue-cycle/compliance analyst checking a file; a patient comparing prices._

## In scope (Phase 1)

- Import CMS v3.0.0 price files (CSV tall, CSV wide, JSON), streamed
- Compare the 20 target services across hospitals (gross, cash, negotiated range)
- Data-quality and compliance report per file, with a score
- Upload a file and see its report

## Out of scope (Phase 1)

_What you are deliberately NOT building, e.g. all 70 shoppable services, insurance estimates, user accounts, cloud hosting (Phase 2)._

## Data

- Source: hospital machine-readable files (public, no patient data)
- Template: CMS v3.0.0; samples in `data/samples`; real files from Week 10

## Target services (20)

| #   | Code  | Type   | Service                                                    |
| --- | ----- | ------ | ---------------------------------------------------------- |
| 1   | 70551 | CPT    | MRI brain without contrast                                 |
| 2   | 72148 | CPT    | MRI lumbar spine without contrast                          |
| 3   | 73721 | CPT    | MRI knee (lower-extremity joint) without contrast          |
| 4   | 74177 | CPT    | CT abdomen and pelvis with contrast                        |
| 5   | 76700 | CPT    | Ultrasound, abdomen complete                               |
| 6   | 80048 | CPT    | Basic metabolic panel                                      |
| 7   | 80053 | CPT    | Comprehensive metabolic panel                              |
| 8   | 85025 | CPT    | Complete blood count (CBC) with differential               |
| 9   | 80061 | CPT    | Lipid panel                                                |
| 10  | 83036 | CPT    | Hemoglobin A1c                                             |
| 11  | 99203 | CPT    | Office visit, new patient (low complexity)                 |
| 12  | 99213 | CPT    | Office visit, established patient (low complexity)         |
| 13  | 99283 | CPT    | Emergency department visit, moderate                       |
| 14  | 99285 | CPT    | Emergency department visit, high                           |
| 15  | 45378 | CPT    | Colonoscopy, diagnostic                                    |
| 16  | 66984 | CPT    | Cataract removal with lens implant                         |
| 17  | 29881 | CPT    | Knee arthroscopy with meniscectomy                         |
| 18  | 470   | MS-DRG | Major hip or knee joint replacement without MCC            |
| 19  | 807   | MS-DRG | Vaginal delivery without sterilization/D&C, without CC/MCC |
| 20  | 788   | MS-DRG | Cesarean section without sterilization, without CC/MCC     |

## Disclaimer

Prices are shown as published by each hospital. PriceLens is a study project, not medical or financial advice.
