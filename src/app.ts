import * as path from 'path';
import { Console } from '../sub-projects/utils/nodejs/console';
import { annotateName } from '../sub-projects/utils/nodejs/decorators';
import { FilesSystem } from '../sub-projects/utils/nodejs/files-system';
import { Generic } from '../sub-projects/utils/nodejs/generic';
import { LoggerExtend } from '../sub-projects/utils/nodejs/logger-extend';
import * as NodeMenu from 'node-menu';

export abstract class App {
    protected className: string = '';
    protected currentMethod: string = '';
    protected readonly processDir = process.cwd();
    protected readonly rootDir = path.join(__dirname, '..', '..');
    protected readonly filesDir = FilesSystem.resolvePath(`${this.rootDir}/files`);
    protected readonly scriptsDir = FilesSystem.resolvePath(`${this.rootDir}/scripts`);
    protected readonly windowsScriptsDir = FilesSystem.resolvePath(`${this.rootDir}/scripts/windows`);
    protected readonly windowsPowershellScript = FilesSystem.resolvePath(`${this.windowsScriptsDir}/windows.ps1`);
    protected error: Error | undefined;
    protected nodeMenu: NodeMenu = require('node-menu');
    protected readonly headerMenu = 'Tools for Projects';
    protected readonly promptMenu = 'Insert an option(With args - Option "arg1" arg2...): ';
    protected readonly delimiterWithTitle: number = 40;
    protected readonly delimiter: number = 40;

    protected constructor(private exitOnError?: boolean) {}

    private _logger: LoggerExtend|undefined;
    protected get logger(): LoggerExtend {
        if (!this._logger) {
            this._logger = new LoggerExtend();
        }
        this._logger.class = this.className;
        this._logger.method = this.currentMethod;
        return this._logger;
    }

    private _console: Console|undefined;
    protected get console(): Console {
        if (!this._console) {
            this._console = new Console();
        }
        return this._console;
    }

    @annotateName
    private configMenu(setClassNameTitle: boolean) {
        const headerTitle = setClassNameTitle ? `  ${this.headerMenu} - ${this.className}`:  `\t${this.headerMenu}`;
        this.nodeMenu = this.nodeMenu.resetMenu()
            .customHeader(() => {
                const title = headerTitle + '\nFor optional args, pass empty string: ""\n';
                this.logger.title(title);
            }).disableDefaultHeader()
            .customPrompt(() => {
                this.logger.prompt(this.promptMenu);
            }).disableDefaultPrompt();
    }

    protected abstract menu(): void;
    protected hasError(): boolean {
        return this.error ? true : false;
    }
    protected processError(error?: Error, noExitTemp?: boolean) {
        this.error = error;
        if (this.hasError()) {
            this.logger.log(Generic.getErrorObjectData(this.error));
            if (!noExitTemp && this.exitOnError) {
                process.exit(1);
            }
        }
    }
    
    protected getOptionalArg(prefix: string, defaultValue?: string, description?: string): string {
        let message = defaultValue && defaultValue.length > 0
            ? `${prefix}(OPTIONAL -> Default: ${defaultValue})`
            : `${prefix}(OPTIONAL)`;

        if (description && description.length > 0) {
            return this.getDescriptionArg(message, description);
        }
        return message;
    }
    protected getDescriptionArg(prefix: string, description: string): string {
        return `${prefix} - ${description}`;
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
            this.error = error;
            this.logger.success(error);
            if (this.exitOnError) {
                process.exit(1);
            }
        }
    }
}