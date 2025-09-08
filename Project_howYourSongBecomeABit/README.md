# Music Chart Analysis

**Tech & Methods:**  
- **Languages/Tools:** Python, Pandas, Matplotlib, Seaborn, Plotly, Jupyter Notebook  
- **Methods:** Data Cleaning & Preprocessing, Logarithmic Regression, Fixed Effects Models, T-tests, ANOVA, Radar & Boxplots, Density Plots, Comparative Analysis  
- **Data:** Top 200 Charts (2015-2021) from Australia, Italy, USA; Sound Features (acousticness, danceability, energy, instrumentalness, liveness, loudness, speechiness, tempo, valence); Technical Features (time_signature, mode, key, explicit)

Analysis of top chart songs from 2015 to 2021 in Australia, Italy, and the USA to understand which features make songs successful and how they survive over time.

**Project Goal:**  
To investigate what factors contribute to a song reaching the top 10 in the charts and whether these factors differ across countries.

**Hypotheses:**  
- Danceability, loudness, and energy are key drivers of chart success.  
- Country-specific preferences may influence which features are most important.  
- Top 10 songs share similar characteristics across countries despite overall differences.

**Approach:**  
- Collected top 200 chart data from 2015–2021 for Australia, Italy, and the USA.  
- Analyzed 13 song features (9 sound, 4 technical).  
- Applied logarithmic regression models and fixed-effects regression to evaluate feature importance.  
- Conducted t-tests and ANOVA to compare differences across countries and between top 10 vs. other songs.  
- Visualized results using boxplots, radar plots, and density plots.

**Key Results:**  
- Danceability, loudness, and energy are the most influential factors for chart ranking.  
- Australians prefer highly danceable and loud songs; Italians prefer energetic tracks; Americans are influenced by artist stardom.  
- Top 10 songs show very similar characteristics across countries, although some minor country-specific patterns exist.  
- The analysis confirms that certain song features consistently predict chart success, while others vary by market.

