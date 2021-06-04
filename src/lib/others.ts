import { Generic } from './../../utils/nodejs-utils/src/lib/generic';
import { EErrorMessages } from './../../utils/nodejs-utils/src/enum/error-messages';
import { FilesSystem } from './../../utils/nodejs-utils/src/lib/files-system';
import { App } from "../app";
import { annotateName } from '../../utils/nodejs-utils/src/lib/decorators';

export class Others extends App {
    constructor() {
        super();
    }
    
    protected menu() {
        this.nodeMenu
            .addDelimiter('-', this.delimiterWithTitle, 'Git')
            .addItem('Add scripts', this.gitAddScripts, this, [{'name': 'file', 'type': 'string'}, {'name': 'extension', 'type': 'string'}])
            .addItem('Rebase', this.gitRebase, this, [{'name': 'branch(Default: master)', 'type': 'string'}])
            .addItem('Reset file', this.gitResetFile, this, [{'name': 'file', 'type': 'string'}, {'name': 'branch(Default: origin/master)', 'type': 'string'}])
            .addItem('Update tags', this.gitUpdateTags, this)
            .addItem('Update submodule', this.gitUpdateSubmodule, this)
            .addItem('Delete submodule', this.gitDeleteSubmodule, this, [{'name': 'submodule(Path: path/to/submodule)', 'type': 'string'}]);
    }

    /**============================================
     *               GIT
     *=============================================**/
    private gitFetchOrigin = () => { this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['fetch', 'origin']}); }

    @annotateName
    private gitAddScripts(file: string) {
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['update-index', `--chmod=+x "${file}"`]});
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['add', `"${file}"`]});
    }

    @annotateName
    private gitRebase(branch?: string) {
        let currentBranchCmd = this.nodejsUtils.console.execSync({cmd: 'git', args: ['branch', '--show-current']});
        if (currentBranchCmd.hasError) {
            this.logger.error(currentBranchCmd.errors);
            return;
        }
        branch = branch && branch.length > 0 ? branch : 'master';
        const currentBranch = currentBranchCmd.stdout as string;
        this.gitFetchOrigin();
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['rebase', branch, branch]});
        if (branch !== currentBranch) {
            this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['rebase', branch, currentBranch]});
        }
    }

    @annotateName
    private gitResetFile(file: string, branch?: string) {
        if (FilesSystem.fileExist(file, false)) {
            branch = branch && branch.length > 0 ? branch : 'origin/master';
            this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['checkout', branch, file]});
        } else {
            this.logger.error(EErrorMessages.invalidFile);
        }
    }

    @annotateName
    private gitUpdateTags() {
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git tag -l | xargs git tag -d && git fetch -t'});
    }

    @annotateName
    private gitUpdateSubmodule() {
        this.gitFetchOrigin();
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'init']});
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'update', '--recursive', '--remote']});
    }

    @annotateName
    private gitDeleteSubmodule (name: string) {
        name = Generic.removeLastCharacter(name, ['/']);
        const status = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'status', `"${name}"`]});
        if (status.hasError) {
            this.logger.error(status.errorStr);
            return;
        }
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'deinit', '-f', `"${name}"`]});
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '-f', `"${name}"`]});
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['config', '-f', '.gitmodules', '--remove-section', `"submodule.${name}"`]});
        if (FilesSystem.readDocument('.gitmodules').trim().length <= 0) {
            this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '-f', '.gitmodules']});
        }
        this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '--cached', `"${name}"`]});
        FilesSystem.deleteFile(`".git/modules/${name}"`);
    }
    /*=============== END OF GIT ==============*/
}