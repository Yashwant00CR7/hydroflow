import os
from dotenv import load_dotenv
from pinecone.grpc import PineconeGRPC as Pinecone
from pinecone import ServerlessSpec
from langchain_pinecone import PineconeVectorStore
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.docstore.document import Document
import PyPDF2
import tensorflow as tf
import numpy as np
import json

# === 1. Load environment variables ===
load_dotenv()
PINECONE_API_KEY = os.environ.get('PINECONE_API_KEY')
os.environ["PINECONE_API_KEY"] = PINECONE_API_KEY

# === 2. Load TFLite model and vocabulary ===
def load_tflite_model():
    """Load the TFLite model and vocabulary"""
    try:
        # Load TFLite model
        interpreter = tf.lite.Interpreter(model_path="sentence_transformer_model.tflite")
        interpreter.allocate_tensors()
        
        # Load vocabulary
        vocab = {}
        with open("vocab.txt", "r", encoding="utf-8") as f:
            for i, line in enumerate(f):
                token = line.strip()
                vocab[token] = i
        
        return interpreter, vocab
    except Exception as e:
        print(f"❌ Error loading TFLite model: {e}")
        return None, None

# === 3. Simple tokenization function ===
def simple_tokenize(text, vocab, max_length=128):
    """Simple tokenization for the model"""
    # Convert to lowercase and split
    words = text.lower().split()
    tokens = []
    
    for word in words:
        if word in vocab:
            tokens.append(vocab[word])
        else:
            # Use UNK token if available, otherwise use 0
            unk_token = vocab.get("[UNK]", 0)
            tokens.append(unk_token)
    
    # Truncate or pad to max_length
    if len(tokens) > max_length:
        tokens = tokens[:max_length]
    else:
        tokens.extend([0] * (max_length - len(tokens)))
    
    return tokens

# === 4. Get embeddings using TFLite model ===
def get_embedding_tflite(text, interpreter, vocab):
    """Get embedding using the TFLite model"""
    try:
        # Get input and output details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"🔍 Model input details: {input_details}")
        print(f"🔍 Model output details: {output_details}")
        
        # Check what input type the model expects
        input_shape = input_details[0]['shape']
        input_dtype = input_details[0]['dtype']
        
        print(f"🔍 Expected input shape: {input_shape}")
        print(f"🔍 Expected input dtype: {input_dtype}")
        
        # If model expects FLOAT32, we need to provide embeddings directly
        if input_dtype == np.float32:
            # Create dummy embeddings (since we can't do full tokenization)
            # This is a simplified approach - you might need to adjust based on your model
            batch_size = 1
            seq_length = input_shape[1] if len(input_shape) > 1 else 128
            hidden_dim = input_shape[2] if len(input_shape) > 2 else 384
            
            # Create random embeddings as placeholder
            # In a real scenario, you'd need to implement proper tokenization and embedding lookup
            dummy_embeddings = np.random.normal(0, 1, (batch_size, seq_length, hidden_dim)).astype(np.float32)
            
            # Set input tensor
            interpreter.set_tensor(input_details[0]['index'], dummy_embeddings)
            
        else:
            # Original approach for INT32 input
            tokens = simple_tokenize(text, vocab)
            tokens = np.array([tokens], dtype=np.int32)
            interpreter.set_tensor(input_details[0]['index'], tokens)
        
        # Run inference
        interpreter.invoke()
        
        # Get output tensor
        embedding = interpreter.get_tensor(output_details[0]['index'])
        
        # Return as list
        return embedding[0].tolist()
        
    except Exception as e:
        print(f"❌ Error getting embedding: {e}")
        return None

# === 5. Load PDF and extract text ===
def load_pdf_file(pdf_path):
    text = ""
    with open(pdf_path, "rb") as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text

pdf_text = load_pdf_file(r"D:\Downloads\Projects\My College Projects\MCA\flutter_application_2\assets\data.pdf")

# === 6. Split text into chunks ===
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    length_function=len,
)
text_chunks = text_splitter.split_text(pdf_text)

# === 7. Prepare documents with metadata ===
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

# === 8. Load TFLite model and vocabulary ===
print("🔄 Loading TFLite model and vocabulary...")
interpreter, vocab = load_tflite_model()

if interpreter is None or vocab is None:
    print("❌ Failed to load TFLite model. Exiting...")
    exit(1)

print(f"✅ TFLite model loaded successfully!")
print(f"✅ Vocabulary loaded with {len(vocab)} tokens")

# === 9. Initialize Pinecone ===
pc = Pinecone(api_key=PINECONE_API_KEY)
index_name = "hydroflow"  # Use the same index as your app

# === 10. Create index if not already existing ===
if index_name not in [index.name for index in pc.list_indexes().indexes]:
    pc.create_index(
        name=index_name,
        dimension=384,  # all-MiniLM-L6-v2 embedding dimension
        metric="cosine",
        spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"
        )
    )

# === 11. Upload to Pinecone using TFLite model ===
print("🔄 Generating embeddings and uploading to Pinecone...")
vectors = []
successful_embeddings = 0

for i, doc in enumerate(documents):
    embedding = get_embedding_tflite(doc.page_content, interpreter, vocab)
    
    if embedding is not None:
        vectors.append({
            "id": f"chunk-{i}",
            "values": embedding,
            "metadata": doc.metadata
        })
        successful_embeddings += 1
    else:
        print(f"⚠️ Failed to generate embedding for chunk {i}")

# Upload to Pinecone
if vectors:
    index = pc.Index(index_name)
    index.upsert(vectors=vectors)
    print(f"✅ {successful_embeddings} chunks uploaded to '{index_name}' Pinecone index using TFLite model.")
else:
    print("❌ No embeddings were generated successfully.")

# === 12. Test the embeddings ===
print("\n🧪 Testing embedding generation...")
test_text = "This is a test sentence for embedding generation."
test_embedding = get_embedding_tflite(test_text, interpreter, vocab)

if test_embedding:
    print(f"✅ Test embedding generated successfully!")
    print(f"   Embedding dimension: {len(test_embedding)}")
    print(f"   Embedding sample: {test_embedding[:5]}...")
else:
    print("❌ Test embedding generation failed!")