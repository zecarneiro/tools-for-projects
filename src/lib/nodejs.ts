import { annotateName } from '../../sub-projects/utils/nodejs/decorators';
import { App } from '../app';

export class Nodejs extends App {
    constructor() {
        super(true);
    }
    
    protected menu() {
        this.nodeMenu
            .addDelimiter('-', this.delimiterWithTitle, 'Angular')
            .addDelimiter('-', this.delimiterWithTitle, 'Node')
            .addItem('Install package on System', this.installPackage, this, [{name: 'package', type: 'string'}])
            .addItem('Get List installed package', this.getListInstalledPackage, this)
    }

    @annotateName
    private getListInstalledPackage() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'npm', args: ['list', '-g --depth=0']}).error);
    }
    @annotateName
    private installPackage(pkg: string) {
        let command: string = this.console.setRootPermissionCmd(`npm i ${pkg}`);
        this.processError(this.console.execSyncWhitoutOutput({cmd: command}).error);
    }
}