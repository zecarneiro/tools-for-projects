import { EErrorMessages } from '../../sub-projects/utils/enum/error-messages';
import { EPlatformType } from '../../sub-projects/utils/enum/platform-type';
import { ICommandInfo } from '../../sub-projects/utils/interface/comand-info';
import { annotateName } from '../../sub-projects/utils/nodejs/decorators';
import { FilesSystem } from '../../sub-projects/utils/nodejs/files-system';
import { App } from '../app';

export class Others extends App {
    constructor() {
        super(true);
    }
    
    protected menu() {
        this.nodeMenu
            // UFW Firewall
            .addDelimiter('-', this.delimiterWithTitle, 'UFW Firewall')
            .addItem('UFW Firewall allow IP', (ip: string) => { this.ufw(ip, true); }, this, [{name: 'IP', type: 'string'}])
            .addItem('UFW Firewall deny IP', (ip: string) => { this.ufw(ip, false); }, this, [{name: 'IP', type: 'string'}])

            // Others
            .addDelimiter('-', this.delimiterWithTitle)
            .addItem('Reset JetBrains IDE', this.resetJetbrains, this)
            .addItem('Install/Uninstall JAVA', (path: string) => { this.java(path); }, this, [{name: this.getDescriptionArg('JAVA_PATH', 'To uninstall pass empty string'), type: 'string'}])
            .addItem('Install Dependency', this.installDependencies, this)
            .addItem('Informations', this.informations, this);
    }

    @annotateName
    private ufw(ip: string, isAllow: boolean) {
        if (!FilesSystem.isValidIP(ip)) {
            this.processError(new Error(EErrorMessages.invalidIp));
        }
        if (FilesSystem.isPlatform(EPlatformType.linux)) {
            if (isAllow) {
                this.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'allow', 'from', ip]});
            } else {
                this.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'deny', 'from', ip]});
                this.console.execSyncWhitoutOutput({cmd: 'sudo', args: ['ufw', 'delete', 'deny', 'from', ip]});
            }
        } else {
            this.processError(new Error(EErrorMessages.invalidPlatform));
        }
    }

    @annotateName
    private java(path: string) {
        path = path.length > 0 ? path : '-u';
        if (path !== '-u' && !FilesSystem.fileExist(path, true)) {
            this.processError(new Error(EErrorMessages.invalidFile));
        }
        const cmd = this.console.setRootPermissionCmd(`${this.windowsPowershellScript} -JAVA_PATH '${path}'`, true);
        this.processError(this.console.execSyncWhitoutOutput({cmd: cmd}, 0).error);
    }

    @annotateName
    private resetJetbrains() {
        switch (FilesSystem.getPlatform().data) {
            case EPlatformType.linux:
                this.logger.warn('Not implemented yet');
                break;
            case EPlatformType.windows:
                this.console.execSyncWhitoutOutput({cmd: this.console.shell.powershell, args: [this.windowsPowershellScript, '-RESET_JETBRAINS']});
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
                commands.push({cmd: 'sudo apt install libz-dev libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc'});
                for (const iterator of commands) {
                    const output = this.console.execSyncWhitoutOutput({cmd: iterator.cmd});
                    if (output.hasError) {
                        break;
                    }
                }
                break;
            case EPlatformType.windows:
                break;
            default:
                throw platform.error;
        }
    }

    private informations() {
        this.logger.info('JETBRAINS PLUGINS - \n\t> GITTOOLBOX: https://plugins.jetbrains.com/plugin/7499-gittoolbox');
    }
}