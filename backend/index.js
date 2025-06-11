import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from "url";
import mongoose from "mongoose";
import dotenv from 'dotenv';
import authRoutes from "./routes/auth.js";
import ingredientRoutes from './routes/ingredient.js';

/* Configuration */
const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use(cors());
app.use(express.urlencoded({ extended: true }));
dotenv.config();
console.log('🔗 MONGODB:', process.env.MONGODB_URL?.substring(0,30) + '...');
console.log('🔐 JWT_SECRET set?', !!process.env.JWT_SECRET);
console.log('🧩 OBJECT_DET URL:', process.env.OBJECT_DETECTION_URL);
console.log('🗝 OPENROUTER_KEY set?', !!process.env.OPENROUTER_API_KEY);


/* Setup database and Port */
const PORT = process.env.PORT || 5000;
mongoose
    .connect(process.env.MONGGODB_URL)
    .then(() => {
        console.log("Database connected")
        app.listen(PORT, () => {
            console.log(`Server port: ${PORT}`)
        });
    })
    .catch((error) => {
        console.log(`${error} did not connect`)
    });

/* Routes */
app.use("/auth", authRoutes);
app.use("/detect/", ingredientRoutes);