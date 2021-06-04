#!/usr/bin/env node
import { App } from './app';
import { Docker } from './lib/docker';
import { Nodejs } from './lib/nodejs';
import { Others } from './lib/others';

export class Index extends App {
    constructor() {
        super(true);
    }

    protected menu() {
        this.nodeMenu.disableDefaultPrompt();
        this.nodeMenu
            .addDelimiter('-', 40, 'Main Menu')
            .addItem('Docker', () => {
                let docker = new Docker();
                docker.run(true, this);
            })
            .addItem('Nodejs', () => {
                let nodejs = new Nodejs();
                nodejs.run(true, this);
            })
            .addItem('Others', () => {
                let others = new Others();
                others.run(true, this);
            });
    }
}

function main() {
    let index = new Index();
    index.run(false);
}
main();
