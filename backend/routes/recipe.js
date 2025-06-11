import express from 'express';
import { generateRecipe } from '../controllers/recipe.js';

const router = express.Router();

router.post('/recipe/', generateRecipe)

export default router;
