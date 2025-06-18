import csv from 'csv-parser';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const recipes = [];

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const loadRecipes = () => {
    return new Promise((resolve, reject) => {
        fs.createReadStream(path.join(__dirname, '../data/indonesian_food_recipe.csv'))
            .pipe(csv())
            .on('data', (row) => {
                recipes.push({
                    title: row.Title,
                    ingredients: row.Ingredients,
                    steps: row.Steps
                });
            })
            .on('end', () => {
                console.log(`${recipes.length} Indonesian recipes loaded`);
                resolve();
            })
            .on('error', reject);
    });
};

export { recipes, loadRecipes };