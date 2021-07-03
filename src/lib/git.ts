import { EErrorMessages } from '../../sub-projects/utils/enum/error-messages';
import { EPlatformType } from '../../sub-projects/utils/enum/platform-type';
import { ICommandInfo } from '../../sub-projects/utils/interface/comand-info';
import { annotateName } from '../../sub-projects/utils/nodejs/decorators';
import { FilesSystem } from '../../sub-projects/utils/nodejs/files-system';
import { Generic } from '../../sub-projects/utils/nodejs/generic';
import { App } from '../app';

export class Git extends App {
    constructor() {
        super(true);
    }
    
    protected menu() {
        this.nodeMenu
            .addItem('Add scripts', this.gitAddScripts, this, [{name: 'file', type: 'string'}])
            .addItem('Rebase', this.gitRebase, this, [{name: this.getOptionalArg('branch', 'master'), type: 'string'}])
            .addItem('Reset file', this.gitResetFile, this, [{name: 'file', type: "string"}, {name: this.getOptionalArg('branch', 'origin/master'), type: 'string'}])
            .addItem('Update tags', this.gitUpdateTags, this)
            .addItem('Update submodule', this.gitUpdateSubmodule, this)
            .addItem('Delete submodule', this.gitDeleteSubmodule, this, [{name: this.getDescriptionArg('submodule', 'path/to/submodule. Go to .gitmodules to see how'), type: 'string'}])
            .addDelimiter('-', this.delimiterWithTitle)
            .addItem('Install Dependency', this.installDependencies, this);
    }

    @annotateName
    private gitFetchOrigin() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['fetch', 'origin']}).error);
    }
    @annotateName
    private gitAddScripts(file: string) {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['update-index', `--chmod=+x "${file}"`]}).error);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['add', `"${file}"`]}).error);
    }
    @annotateName
    private gitRebase(branch?: string) {
        let currentBranchCmd = this.console.execSync({cmd: 'git', args: ['branch', '--show-current']});
        this.processError(currentBranchCmd.error);
        branch = branch && branch.length > 0 ? branch : 'master';
        const currentBranch = currentBranchCmd.stdout as string;
        this.gitFetchOrigin();
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['rebase', `origin/${branch}`, branch]}).error);
        if (branch !== currentBranch) {
            this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['rebase', branch, currentBranch]}).error);
        }
    }
    @annotateName
    private gitResetFile(file: string, branch?: string) {
        if (FilesSystem.fileExist(file, false)) {
            branch = branch && branch.length > 0 ? branch : 'origin/master';
            this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['checkout', branch, file]}).error);
        } else {
            this.processError(new Error(EErrorMessages.invalidFile));
        }
    }
    @annotateName
    private gitUpdateTags() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git tag -l | xargs git tag -d && git fetch -t'}).error);
    }
    @annotateName
    private gitUpdateSubmodule() {
        this.gitFetchOrigin();
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'init']}).error);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'update', '--recursive', '--remote']}).error);
    }
    @annotateName
    private gitDeleteSubmodule (name: string) {
        name = Generic.removeLastCharacter(name, ['/']);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'status', `"${name}"`]}).error);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['submodule', 'deinit', '-f', `"${name}"`]}).error);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '-f', `"${name}"`]}).error);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['config', '-f', '.gitmodules', '--remove-section', `"submodule.${name}"`]}).error);
        if (FilesSystem.readDocument('.gitmodules').trim().length <= 0) {
            this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '-f', '.gitmodules']}).error);
        }
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'git', args: ['rm', '--cached', `"${name}"`]}).error);
        FilesSystem.deleteFile(`".git/modules/${name}"`);
    }
    @annotateName
    private installDependencies() {
        let commands: ICommandInfo[] = [];
        const platform = FilesSystem.getPlatform();
        switch (platform.data) {
            case EPlatformType.linux:
                commands.push({cmd: 'sudo apt install git'});
                commands.push({cmd: 'sudo apt install libz-dev libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc'});
                for (const iterator of commands) {
                    this.processError(this.console.execSyncWhitoutOutput({cmd: iterator.cmd}).error);
                }
                break;
            case EPlatformType.windows:
                this.logger.info('*Git - Link install:* https://git-scm.com/downloads');
                break;
            default:
                this.processError(platform.error);
        }
    }
}