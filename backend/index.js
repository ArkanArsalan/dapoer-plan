import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from "url";
import mongoose from "mongoose";
import dotenv from 'dotenv';

/* Configuration */
const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use(cors());
app.use(express.urlencoded({ extended: true }));
dotenv.config();

/* Setup database and Port */
const PORT = process.env.PORT || 5000;
mongoose
    .connect(process.env.MONGGO_URL)
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
