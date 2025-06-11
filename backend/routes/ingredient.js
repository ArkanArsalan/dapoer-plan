import express from 'express';
import { detectIngredient } from '../controllers/ingredient.js';
import { detectIngredientLLM } from '../controllers/ingredient.js';

const router = express.Router();

router.post('/ingredient', detectIngredient);
router.post('/ingredient/llm', detectIngredientLLM);

export default router;
