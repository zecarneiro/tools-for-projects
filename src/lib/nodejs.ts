import { App } from "../app";

export class Nodejs extends App {
    constructor() {
        super();
    }
    
    protected menu() {
        this.nodeMenu
            .addDelimiter('-', this.delimiterWithTitle, 'Angular')
            .addDelimiter('-', this.delimiterWithTitle, 'Node')
            .addItem('Install package on System', this.installPackage, this, [{'name': 'package', 'type': 'string'}])
            .addItem('Get List installed package', () => {
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'npm', args: ['list', '-g --depth=0']});
            })
    }

    private installPackage(pkg: string) {
        let command: string = this.nodejsUtils.console.setRootPermissionCmd(`npm i ${pkg}`);
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: command});
    }
}