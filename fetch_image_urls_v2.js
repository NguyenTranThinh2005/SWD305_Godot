const https = require('https');

const titles = [
    'File:Halong Bay in Vietnam.jpg',
    'File:Collecting lotus flowers, Vietnam.jpg',
    'File:Vietnamese girl wearing ao dai 3.jpg',
    'File:Vietnamese musical instrument Dan bau 2 (cropped).jpg',
    'File:Hanoi Vietnam Mausoleum-of-Ho-Chi-Minh-01.jpg',
    'File:Mekong delta.jpg',
    'File:Bamboo at Wushantou.jpg',
    'File:Cat03.jpg',
    'File:Argentine_Dog.jpg',
    'File:Red_Apple.jpg',
    'File:Banana-Single.jpg',
    'File:Left_side_of_Flying_Pigeon.jpg',
    'File:Honda_Super_Cub_C125_Abs_-_Pearl_Niltava_Blue-001.jpg',
    'File:Semicolon.png',
    'File:Kim Vân Kiều tân truyện.jpg',
    'File:Tượng đài cụ Nguyễn Du.jpg'
];

function fetchUrls(batch) {
    const url = `https://commons.wikimedia.org/w/api.php?action=query&titles=${batch.map(t => encodeURIComponent(t)).join('|')}&prop=imageinfo&iiprop=url&format=json`;
    
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
                        console.log(`${page.title} -> ${page.imageinfo[0].url}`);
                    } else {
                        console.log(`${page.title} -> MISSING`);
                    }
                }
            } catch (e) {
                console.error("Parse error", e);
            }
        });
    });
}

// Batching to avoid long URLs
for (let i = 0; i < titles.length; i += 10) {
    fetchUrls(titles.slice(i, i + 10));
}
