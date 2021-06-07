import { EShellType } from './../../utils/nodejs-utils/src/enum/shell-type';
import { EPlatformType } from './../../utils/nodejs-utils/src/enum/platform-type-enum';
import { ICommandInfo } from './../../utils/nodejs-utils/src/interface/comand-info';
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
            // Git
            .addDelimiter('-', this.delimiterWithTitle, 'Git')
            .addItem('Add scripts', this.gitAddScripts, this, [{'name': 'file', 'type': 'string'}, {'name': 'extension', 'type': 'string'}])
            .addItem('Rebase', this.gitRebase, this, [{'name': 'branch(Default: master)', 'type': 'string'}])
            .addItem('Reset file', this.gitResetFile, this, [{'name': 'file', 'type': 'string'}, {'name': 'branch(Default: origin/master)', 'type': 'string'}])
            .addItem('Update tags', this.gitUpdateTags, this)
            .addItem('Update submodule', this.gitUpdateSubmodule, this)
            .addItem('Delete submodule', this.gitDeleteSubmodule, this, [{'name': 'submodule(Path: path/to/submodule)', 'type': 'string'}])

            // UFW Firewall
            .addDelimiter('-', this.delimiterWithTitle, 'UFW Firewall')
            .addItem('UFW Firewall allow IP', (ip: string) => {
                if (!FilesSystem.isValidIP(ip)) {
                    this.logger.error(EErrorMessages.invalidIp);
                    return;
                }
                if (FilesSystem.isPlatform(EPlatformType.linux)) {
                    this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'allow', 'from', ip]});
                } else {
                    this.logger.error(EErrorMessages.invalidPlatform);
                }
            }, this, [{'name': 'IP', 'type': 'string'}])
            .addItem('UFW Firewall deny IP', (ip: string) => {
                if (!FilesSystem.isValidIP(ip)) {
                    this.logger.error(EErrorMessages.invalidIp);
                    return;
                }
                if (FilesSystem.isPlatform(EPlatformType.linux)) {
                    this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'deny', 'from', ip]});
                    this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'delete', 'deny', 'from', ip]});
                } else {
                    this.logger.error(EErrorMessages.invalidPlatform);
                }
            }, this, [{'name': 'IP', 'type': 'string'}])

            // Others
            .addDelimiter('-', this.delimiterWithTitle)
            .addItem('Reset JetBrains IDE', this.resetJetbrains, this)
            .addItem('Install/Uninstall JAVA', (path: string) => {
                path = path.length > 0 ? path : '-u';
                if (path !== '-u' && !FilesSystem.fileExist(path, true)) {
                    this.logger.error(EErrorMessages.invalidFile);
                    return;
                }
                const cmd = this.nodejsUtils.console.setRootPermissionCmd(`${this.windowsPowershellScript} -JAVA_PATH '${path}'`, true);
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: cmd}, 0, EShellType.powershell);
            }, this, [{'name': 'JAVA PATH(To uninstall pass empty string)', 'type': 'string'}])
            .addItem('Install Dependency', this.installDependencies, this);
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

    @annotateName
    private resetJetbrains() {
        switch (FilesSystem.getPlatform().data) {
            case EPlatformType.linux:
                this.logger.warn('Not implemented yet');
                break;
            case EPlatformType.windows:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: EShellType.powershell, args: [this.windowsPowershellScript, '-RESET_JETBRAINS']});
                break;
            default:
                this.logger.warn('Not implemented yet');
                break;
        }
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
                    const output = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: iterator.cmd});
                    if (output.hasError) {
                        break;
                    }
                }
                break;
            case EPlatformType.windows:
                this.logger.info('*Git - Link install:* https://git-scm.com/downloads');
                break;
            default:
                throw platform.error;
        }
    }
}