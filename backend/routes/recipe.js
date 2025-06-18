import express from 'express';
import { generateRecipe, getRandomRecipe, getRecipes } from '../controllers/recipe.js';

const router = express.Router();

router.post('/generate/', generateRecipe)
router.get('/', getRecipes)
router.get('/random', getRandomRecipe)

export default router;
