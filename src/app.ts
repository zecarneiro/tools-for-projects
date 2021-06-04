import { Generic } from './../utils/nodejs-utils/src/lib/generic';
import { FilesSystem } from './../utils/nodejs-utils/src/lib/files-system';
import { Logger } from 'logdown';
import { EMessagesType } from '../utils/nodejs-utils/src/enum/messages-type-enum';
import { NodejsUtils } from '../utils/nodejs-utils/src';
import { annotateName } from '../utils/nodejs-utils/src/lib/decorators';
import * as path from 'path';

export abstract class App {
    protected className: string = '';
    protected currentMethod: string = '';
    protected readonly processDir = process.cwd();
    protected readonly rootDir = path.join(__dirname, '..', '..');
    protected readonly filesDir = FilesSystem.resolvePath(`${this.rootDir}/files`);
    protected readonly scriptsDir = FilesSystem.resolvePath(`${this.rootDir}/scripts`);
    protected error: Error | undefined;
    protected nodeMenu = require('node-menu');
    protected readonly headerMenu = 'Tools for Projects';
    protected readonly promptMenu = 'Insert an option(With args - Option "arg1" arg2...): ';
    protected readonly delimiterWithTitle: number = 40;
    protected readonly delimiter: number = 40;
    protected nodejsUtils: NodejsUtils;

    constructor(private exitOnError?: boolean) {
        this.nodejsUtils = new NodejsUtils();
    }

    @annotateName
    private configMenu(setClassNameTitle: boolean) {
        const headerTitle = setClassNameTitle ? `  ${this.headerMenu} - ${this.className}`:  `\t${this.headerMenu}`;
        this.nodeMenu = this.nodeMenu.resetMenu()
            .customHeader(() => {
                Generic.printMessages(`${headerTitle}\n\n`, EMessagesType.title);
            }).disableDefaultHeader()
            .customPrompt(() => {
                Generic.printMessages(this.promptMenu, EMessagesType.other);
            }).disableDefaultPrompt();
    }

    protected abstract menu(): void;
    protected haveError(): boolean {
        return this.error ? true : false;
    }
    protected get logger(): Logger {
        return Generic.getLogger(`${this.className}::${this.currentMethod} `);
    }

    @annotateName
    run(setClassNameTitle: boolean, returnOption?: App) {
        try {
            this.configMenu(setClassNameTitle);
            this.menu();
            this.nodeMenu.addDelimiter('*', this.delimiter);
            if (returnOption) {
                this.nodeMenu.addItem('Back', () => { returnOption.run(false); });
            }
            this.nodeMenu.start();
        } catch (error) {
            this.error = new Error(error);
            this.logger.error(this.error);
            if (this.exitOnError) {
                process.exit(1);
            }
        }
    }
}