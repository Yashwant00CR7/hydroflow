import os
from dotenv import load_dotenv
from pinecone.grpc import PineconeGRPC as Pinecone
from pinecone import ServerlessSpec
from langchain_pinecone import PineconeVectorStore
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.docstore.document import Document
import PyPDF2
import openai

# === 1. Load environment variables ===
load_dotenv()
PINECONE_API_KEY = os.environ.get('PINECONE_API_KEY')
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
os.environ["PINECONE_API_KEY"] = PINECONE_API_KEY
openai.api_key = OPENAI_API_KEY

# === 2. Load PDF and extract text ===
def load_pdf_file(pdf_path):
    text = ""
    with open(pdf_path, "rb") as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text

pdf_text = load_pdf_file(r"D:\Downloads\Projects\My College Projects\MCA\flutter_application_2\assets\data.pdf")

# === 3. Split text into chunks ===
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    length_function=len,
)
text_chunks = text_splitter.split_text(pdf_text)

# === 4. Prepare documents with metadata (store chunk as 'text') ===
documents = [
    Document(
        page_content=chunk,
        metadata={
            "text": chunk,  # <--- This is the key your Dart app expects!
            "source": r"D:\Downloads\Projects\My College Projects\MCA\flutter_application_2\assets\data.pdf",
            "chunk": i
        }
    )
    for i, chunk in enumerate(text_chunks)
]

# === 5. Get OpenAI embeddings (1536-dim) ===
def get_openai_embedding(text):
    response = openai.Embedding.create(
        input=text,
        model="text-embedding-ada-002"
    )
    return response['data'][0]['embedding']

# === 6. Initialize Pinecone ===
pc = Pinecone(api_key=PINECONE_API_KEY)
index_name = "hydroflow"  # Use the same index as your app

# === 7. Create index if not already existing ===
if index_name not in [index.name for index in pc.list_indexes().indexes]:
    pc.create_index(
        name=index_name,
        dimension=1536,  # OpenAI embedding dimension
        metric="cosine",
        spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"
        )
    )

# === 8. Upload to Pinecone ===
vectors = []
for i, doc in enumerate(documents):
    embedding = get_openai_embedding(doc.page_content)
    vectors.append({
        "id": f"chunk-{i}",
        "values": embedding,
        "metadata": doc.metadata
    })

index = pc.Index(index_name)
index.upsert(vectors=vectors)

print(f"✅ {len(vectors)} chunks uploaded to '{index_name}' Pinecone index.")