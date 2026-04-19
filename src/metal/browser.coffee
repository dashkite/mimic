import puppeteer from "puppeteer"

export browser = -> [ await puppeteer.launch() ]

browser.with = ( options ) -> -> [ await puppeteer.launch options ]
