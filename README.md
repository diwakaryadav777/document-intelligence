# LedgerLens – Document Intelligence

AI-powered financial document processing system that classifies, extracts, validates, and enables natural-language search across invoices, receipts, bank statements, and purchase orders.

---

## Features

- **OCR Extraction** — Tesseract + PyMuPDF + pdfplumber for PDFs and scanned images
- **AI Classification** — GPT-4o-mini classifies document type with confidence score; rule-based fallback
- **Field Extraction** — per-document-type structured field extraction (invoice number, vendor, amounts, GST, etc.)
- **Validation** — amount cross-checks, GST format validation, date format checks
- **Duplicate Detection** — SHA-256 content hash deduplication
- **Semantic Search** — OpenAI embeddings + cosine similarity search across all documents
- **Analytics Dashboard** — volume trends, amount trends, validation status breakdown
- **Export** — JSON and CSV export per document

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend API | FastAPI + Uvicorn |
| Frontend | Streamlit |
| OCR | Tesseract OCR, PyMuPDF, pdfplumber |
| AI / LLM | OpenAI GPT-4o-mini |
| Embeddings | OpenAI text-embedding-3-small |
| Vector Search | FAISS + cosine similarity |
| Database | SQLite via SQLAlchemy |
| NLP | spaCy |

---

## Architecture

```
User uploads document
        │
        ▼
   FastAPI Backend
        │
        ├─► OCR Service         (Tesseract / pdfplumber / PyMuPDF)
        │         │ raw text
        ├─► Classification      (GPT-4o-mini → invoice/receipt/bank_statement/...)
        │         │ document type
        ├─► Extraction Service  (GPT-4o-mini → structured JSON fields)
        │         │ extracted data
        ├─► Validation Service  (amount math, GST regex, date format)
        │         │ errors list
        ├─► Summary Generation  (GPT-4o-mini → 2–3 sentence summary)
        │         │
        ├─► Embedding + FAISS   (semantic search index)
        │
        └─► SQLite Database     (stores all results)

Streamlit Frontend ◄─────── REST API calls ──────── FastAPI on :8000
       :8501
```

### Directory Structure

```
project/
├── backend/
│   ├── main.py                    # FastAPI app, CORS, startup
│   ├── config.py                  # Pydantic settings from .env
│   ├── database.py                # SQLAlchemy engine + session
│   ├── models/document.py         # ORM model
│   ├── schemas/document.py        # Pydantic request/response schemas
│   ├── routers/
│   │   ├── documents.py           # upload, list, get, delete, search, export
│   │   └── analytics.py           # summary stats, monthly trends, amount trends
│   ├── services/
│   │   ├── ocr_service.py         # text extraction from PDF/image
│   │   ├── classification_service.py  # document type classification
│   │   ├── extraction_service.py  # per-type field extraction + summary
│   │   ├── validation_service.py  # amount/GST/date validation
│   │   └── search_service.py      # embeddings + semantic search
│   └── utils/file_utils.py        # file helpers, hash, extension checks
├── frontend/
│   └── app.py                     # Streamlit: Dashboard, Upload, Library, Search, Analytics
├── uploads/                       # uploaded documents (git-ignored)
├── data/                          # SQLite DB (git-ignored)
├── requirements.txt
├── .env.example                   # required env vars (no real keys)
├── run_backend.sh
└── run_frontend.sh
```

---

## Setup & Run

### Prerequisites

- Python 3.10+
- Tesseract OCR

```bash
# macOS
brew install tesseract

# Ubuntu/Debian
sudo apt-get install tesseract-ocr
```

### 1. Clone & install dependencies

```bash
git clone <your-repo-url>
cd project
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` and set your OpenAI API key:

```
OPENAI_API_KEY=sk-...
```

### 3. Start the backend

```bash
./run_backend.sh
# FastAPI running at http://localhost:8000
# Interactive API docs at http://localhost:8000/docs
```

### 4. Start the frontend (new terminal)

```bash
./run_frontend.sh
# Streamlit app at http://localhost:8501
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/documents/upload` | Upload and process a document |
| GET | `/documents/` | List all documents (filterable) |
| GET | `/documents/{id}` | Get full document details |
| DELETE | `/documents/{id}` | Delete a document |
| POST | `/documents/search` | Natural language semantic search |
| GET | `/documents/{id}/export` | Export as JSON or CSV |
| GET | `/analytics/summary` | Overall stats |
| GET | `/analytics/by-month` | Monthly volume |
| GET | `/analytics/amount-trends` | Transaction amounts over time |

---

## Supported Document Types

- **Invoice** — invoice number, vendor, customer, line items, GST, total
- **Receipt** — merchant, date, items, payment method, total
- **Bank Statement** — account info, transactions, opening/closing balance
- **Purchase Order** — PO number, buyer, supplier, line items, delivery terms
- **Tax Document** — GSTIN, CGST/SGST/IGST breakdown, HSN codes

---

## Environment Variables

See `.env.example`:

```
OPENAI_API_KEY=           # Required — OpenAI API key
DATABASE_URL=             # Optional — defaults to sqlite:///./data/ledgerlens.db
UPLOAD_DIR=               # Optional — defaults to ./uploads
MAX_FILE_SIZE_MB=         # Optional — defaults to 20
EMBEDDING_MODEL=          # Optional — defaults to text-embedding-3-small
LLM_MODEL=                # Optional — defaults to gpt-4o-mini
```
