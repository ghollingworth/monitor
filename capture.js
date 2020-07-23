const puppeteer = require('puppeteer');

function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
};

var myArgs = process.argv.slice(2);

(async () => {
  const browser = await puppeteer.launch({executablePath:'/usr/bin/chromium',headless:true,args: ['--user-data-dir=/home/pi/.config/chromium']});
  const page = await browser.newPage();
  await page.setViewport({width:1024,height:2048})
  await page.addStyleTag({
  content: `
    html {
      -webkit-print-color-adjust: exact !important;
      -webkit-filter: opacity(1) !important;
    }
  `
  });  
  await page.goto(myArgs[0]);
  await timeout(5000)
  await page.screenshot({path: myArgs[1]});

  await browser.close();
})();

