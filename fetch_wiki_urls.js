const https = require('https');
const fs = require('fs');

const files = [
    'Vi-Hà_Nội.ogg', 'Vi-Sài_Gòn.ogg', 'Vi-Huế.ogg', 'Vi-Hải_Phòng.ogg',
    'Vi-Bình_Dương.ogg', 'Vi-Thái_Bình.ogg', 'Vi-Đồng_Nai.ogg', 'Vi-Bà_Rịa-Vũng_Tàu.ogg',
    'Vi-TP_Hồ_Chí_Minh.ogg', 'Vi-Tây_Ninh.ogg', 'Vi-Long_An.ogg', 'Vi-Cần_Thơ.ogg',
    'Vi-Bến_Tre.ogg', 'Vi-Vĩnh_Long.ogg', 'Vi-Tiền_Giang.ogg', 'Vi-Đà_Nẵng.ogg'
];

function fetchUrls(titles) {
    const url = `https://commons.wikimedia.org/w/api.php?action=query&titles=${titles.map(t => 'File:' + encodeURIComponent(t)).join('|')}&prop=imageinfo&iiprop=url&format=json`;
    
    https.get(url, (res) => {
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
            }
        });
    });
}

// Split into batches of 10
for (let i = 0; i < files.length; i += 10) {
    fetchUrls(files.slice(i, i + 10));
}
