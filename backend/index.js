const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const axios = require('axios');
const cors = require('cors'); 
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());

// Supabase client
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

// Middleware
app.use(express.json());

// Spoonacular API key
const SPOONACULAR_API_KEY = process.env.SPOONACULAR_API_KEY;

app.get('/api/proxy', async (req, res) => {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({ error: 'URL parameter is required' });
  }

  try {
    const response = await axios.get(url, { responseType: 'arraybuffer' });
    res.set('Content-Type', response.headers['content-type']);
    res.send(response.data);
  } catch (error) {
    console.error('Error fetching image:', error.message);
    res.status(500).json({ error: 'Failed to fetch image' });
  }
});

// Fetch recipes from Spoonacular API
app.get('/api/recipes', async (req, res) => {
  const { cuisine, diet, time } = req.query;
  try {
    const response = await axios.get(`https://api.spoonacular.com/recipes/complexSearch`, {
      params: {
        apiKey: SPOONACULAR_API_KEY,
        cuisine,
        diet,
        maxReadyTime: time,
      },
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch recipes' });
  }
});

// Save favorite recipe
app.post('/api/favorites', async (req, res) => {
  const { user_id, recipe_id } = req.body;
  try {
    const { data, error } = await supabase
      .from('favorites')
      .insert([{ user_id, recipe_id }]);
    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to save favorite' });
  }
});

// Get user favorites
app.get('/api/favorites/:user_id', async (req, res) => {
  const { user_id } = req.params;
  try {
    const { data, error } = await supabase
      .from('favorites')
      .select('*')
      .eq('user_id', user_id);
    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch favorites' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});