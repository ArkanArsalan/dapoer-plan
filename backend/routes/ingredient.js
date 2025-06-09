import express from 'express';
import { detectIngredient } from '../controllers/ingredient.js';

const router = express.Router();

router.post('/ingredient', detectIngredient);

export default router;
