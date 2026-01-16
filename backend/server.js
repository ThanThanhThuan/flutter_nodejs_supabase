require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const multer = require('multer');
const cors = require('cors');

const app = express();
const upload = multer({ storage: multer.memoryStorage() }); // Handle files in memory
app.use(cors());
app.use(express.json());

// Initialize Supabase
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
const BUCKET = 'contact-images';

// 1. GET Contacts
app.get('/contacts', async (req, res) => {
    const { data, error } = await supabase.from('contacts').select('*').order('id', { ascending: false });
    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
});

// 2. CREATE Contact (with Image)
app.post('/contacts', upload.single('image'), async (req, res) => {
    const { name, phone } = req.body;
    const file = req.file;
    let imageUrl = null;

    if (file) {
        // Upload image to Supabase Storage
        const fileName = `${Date.now()}_${file.originalname}`;
        const { data: uploadData, error: uploadError } = await supabase.storage
            .from(BUCKET)
            .upload(fileName, file.buffer, { contentType: file.mimetype });

        if (uploadError) return res.status(500).json({ error: uploadError.message });

        // Get Public URL
        const { data: urlData } = supabase.storage.from(BUCKET).getPublicUrl(fileName);
        imageUrl = urlData.publicUrl;
    }

    // Save to DB
    const { data, error } = await supabase
        .from('contacts')
        .insert([{ name, phone, image_url: imageUrl }])
        .select();

    if (error) return res.status(500).json({ error: error.message });
    res.json(data[0]);
});

// 3. DELETE Contact
app.delete('/contacts/:id', async (req, res) => {
    const { id } = req.params;
    const { error } = await supabase.from('contacts').delete().eq('id', id);
    if (error) return res.status(500).json({ error: error.message });
    res.json({ message: 'Deleted' });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));