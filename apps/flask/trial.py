import firebase_admin
from firebase_admin import credentials, firestore

# Replace 'path/to/your/serviceAccountKey.json' with the path to your Firebase service account key file
cred = credentials.Certificate(r'C:\Users\Girish\.vscode\programs\sahaya\apps\flask\firebase.json')
firebase_admin.initialize_app(cred)

# Get a reference to the Firestore database
db = firestore.client()

def get_data_from_firestore(collection_name, key):
    # Get the document reference
    doc_ref = db.collection(collection_name).document(key)

    # Get the document data
    doc_data = doc_ref.get().to_dict()

    return doc_data.get(key, [])

# Replace 'needs_and_gives' with the name of your collection
collection_name = 'needs_and_gives'

# Retrieve "need" data
need_data = get_data_from_firestore(collection_name, 'need')
print("Need Data:")
print(need_data)

# Retrieve "give" data
give_data = get_data_from_firestore(collection_name, 'give')
print("Give Data:")
print(give_data)
