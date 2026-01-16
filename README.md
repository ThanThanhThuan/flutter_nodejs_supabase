# Contact Management App
This project is a Contact Management App that allows users to Create, Read, and Delete contacts with profile images.
It demonstrates a separation of concerns where the mobile app does not talk directly to the database, but rather through a custom REST API.

<img width="503" height="892" alt="image" src="https://github.com/user-attachments/assets/4bae0644-9aa5-47a2-91c9-9899872c5bad" />


A. Tech Stack

    Frontend: Flutter (Mobile App)

    State Management: Riverpod (StateNotifierProvider)

    UI Layout: Slivers (CustomScrollView, SliverAppBar, SliverList)

    Backend: Node.js + Express

    Database & Storage: Supabase (PostgreSQL + S3-compatible Object Storage)

B. Architecture Flow

    The User Interface (Flutter)

        Uses Slivers to create a fancy scrolling effect where the header image shrinks/expands.

        Uses Riverpod to hold the state (List<Contact>). When the UI needs data, it calls the Provider.

        When adding a contact, it packages the text fields and the image file into a Multipart Request and sends it to the Node.js server.

    The API Layer (Node.js/Express)

        Acts as a secure proxy.

        GET /contacts: Queries Supabase for the list of contacts.

        POST /contacts:

            Receives the file using multer.

            Uploads the raw image file to Supabase Storage.

            Retrieves the public URL of the uploaded image.

            Inserts the Name, Phone, and Image URL into the Supabase Database.

        DELETE /contacts/:id: Tells Supabase to delete the record.

    The Data Layer (Supabase)

        Storage Bucket (contact-images): Stores the actual .jpg/.png files.

        Table (contacts): Stores the metadata (ID, Name, Phone) and the reference string (URL) pointing to the storage bucket.

C. Key Features

    CRUD Operations: Full capability to Create, Read, and Delete.

    Image Handling: Handles binary image data upload from mobile -> server -> cloud storage.

    Reactive UI: The UI updates instantly when a contact is added or removed without needing a full page reload (thanks to Riverpod).

    Security: API keys (SUPABASE_KEY) are kept on the server (.env), not exposed in the Flutter app code.
