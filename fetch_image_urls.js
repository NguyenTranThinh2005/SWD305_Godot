const https = require('https');
const fs = require('fs');

const files = [
    'Cat03.jpg', 'Argentine_Dog.jpg', 'Red_Apple.jpg', 'Banana-Single.jpg',
    'Left_side_of_Flying_Pigeon.jpg', 'Honda_Super_Cub_C125_Abs_-_Pearl_Niltava_Blue-001.jpg',
    'Paloma_domestica_-_pigeon_white.jpg', 'Bamboo_at_Wushantou.jpg',
    'Nelumbo_nucifera_-_Nelumbonaceae_-_Santuario_della_Beata_Vergine_delle_Grazie_-_Curtatone_-_Mantua_-_Italy_-_07.jpg',
    'Halong_Bay_Panorama.jpg', 'Dan_bau.jpg', 'Ao_dai_Vietnam.jpg',
    'Truyen_Kieu_ban_1866.jpg', 'Nguyen_Du_Portrait.jpg', 'Mekong_Delta_satellite.jpg',
    'Ho_Chi_Minh_Mausoleum_2013-03.jpg', 'Semicolon.png', 'Chu_Nom_manuscript.jpg'
];

function fetchUrls(titles) {
    const url = `https://commons.wikimedia.org/w/api.php?action=query&titles=${titles.map(t => 'File:' + encodeURIComponent(t)).join('|')}&prop=imageinfo&iiprop=url&format=json`;
    
    https.get(url, { headers: { 'User-Agent': 'VNEG_Bot/1.0 (contact: test@example.com)' } }, (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
            try {
                const json = JSON.parse(data);
                const pages = json.query.pages;
                for (const id in pages) {
                    const page = pages[id];
                    if (page.imageinfo) {
                        console.log(`${page.title.replace('File:', '')} -> ${page.imageinfo[0].url}`);
                    } else {
                        console.log(`${page.title.replace('File:', '')} -> MISSING`);
                    }
                }
            } catch (e) {
                console.error("Parse error", e);
                console.log("Raw data:", data);
            }
        });
    });
}

// Split into batches of 10
for (let i = 0; i < files.length; i += 10) {
    fetchUrls(files.slice(i, i + 10));
}
