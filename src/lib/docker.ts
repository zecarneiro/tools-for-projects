import { FilesSystem } from './../../utils/nodejs-utils/src/lib/files-system';
import { Generic } from './../../utils/nodejs-utils/src/lib/generic';
import { ICommandInfo } from './../../utils/nodejs-utils/src/interface/comand-info';
import { EPortainerOperation } from './../enum/portainer-operation';
import { IPortainerCommands } from './../interface/portainer-commands';
import { App } from "../app";
import { EPlatformType } from "../../utils/nodejs-utils/src/enum/platform-type-enum";
import { EDockerOperation } from '../enum/docker-operation';
import { annotateName } from '../../utils/nodejs-utils/src/lib/decorators';

export class Docker extends App {
    constructor() {
        super();
    }
    
    protected menu() {
        this.nodeMenu
            // Portainer
            .addDelimiter('-', this.delimiterWithTitle, 'Portainer')
            .addItem('Install/Update', this.operationsPortainer, this, [
                {'name': 'type', 'type': 'string'},
                {'name': 'password', 'type': 'string'}
            ])
            .addItem('Uninstall', () => { this.operationsPortainer(EPortainerOperation.uninstall); }, this)
            .addItem('Reset Password', () => { this.operationsPortainer(EPortainerOperation.resetPassword); }, this)
            .addItem('Stop', () => { this.operationsPortainer(EPortainerOperation.stop); }, this)
            .addItem('Start', () => { this.operationsPortainer(EPortainerOperation.start); }, this)

            // Docker Operations
            .addDelimiter('-', this.delimiterWithTitle, 'Operations')
            .addItem('Stop Container', (name: string) => { this.operationsDocker(EDockerOperation.startContainer, name); }, this, [{'name': 'name', 'type': 'string'}])
            .addItem('Start Container', (name: string) => { this.operationsDocker(EDockerOperation.startContainer, name); }, this, [{'name': 'name', 'type': 'string'}])
            .addItem('Remove Container', (name: string) => { this.operationsDocker(EDockerOperation.removeContainer, name); }, this, [{'name': 'name', 'type': 'string'}])
            .addItem('Remove Volume', (name: string) => { this.operationsDocker(EDockerOperation.removeVolume, name); }, this, [{'name': 'name', 'type': 'string'}])
            .addItem('Remove Image', () => { this.operationsDocker(EDockerOperation.removeImage); }, this)
            .addItem('Remove All Unused', () => { this.operationsDocker(EDockerOperation.removeAllUnused); }, this)
            .addItem('Remove All', () => { this.operationsDocker(EDockerOperation.removeAll); }, this)

            // Others
            .addDelimiter('-', this.delimiterWithTitle)
            .addItem('Informations', this.informations, this)
            .addItem('Install Dependency', this.installDependencies, this);
    }

    /**============================================
     *!               PORTAINER
     *=============================================**/
     @annotateName
    private getPortainerCommands(password?: string): IPortainerCommands {
        let passwordArg: string = '';
        if (password && password.length > 0) {
            const hashPassword = Generic.hashPassword('admin', password ? password : '');
            if (hashPassword.hasError) {
                this.logger.error(hashPassword.errorStr);
            } else {
                passwordArg = `--admin-password="${hashPassword.data}"`;
            }
        }
        
        return {
            createVolume: {
                cmd: 'docker',
                args: ['volume', 'create', 'portainer_data']
            },
            install: {
                cmd: 'docker',
                args: [
                    'run -d -p 8000:8000 -p 9000:9000',
                    '--name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce',
                    passwordArg
                ]
            },
            resetPassword: {
                cmd: 'docker',
                args: ['run --rm -v portainer_data:/data portainer/helper-reset-password']
            }
        };
    }

    @annotateName
    private operationsPortainer(type: string, password?: string) {
        const containerName = 'portainer';
        let portainerCmd = this.getPortainerCommands(password);
        switch (type) {
            case EPortainerOperation.install:
                if (!this.nodejsUtils.console.execSyncWhitoutOutput({cmd: portainerCmd.createVolume.cmd, args: portainerCmd.createVolume.args}).hasError) {
                    this.nodejsUtils.console.execSyncWhitoutOutput({cmd: portainerCmd.install.cmd,args: portainerCmd.install.args});
                }
                this.logger.warn('If password not working, please reset password or stop and remove all unused');
                break;
            case EPortainerOperation.uninstall:
                this.operationsDocker(EDockerOperation.stopContainer, containerName);
                this.operationsDocker(EDockerOperation.removeContainer, containerName);
                this.operationsDocker(EDockerOperation.removeImage);
                break;
            case EPortainerOperation.update:
                this.operationsPortainer(EPortainerOperation.uninstall);
                this.operationsPortainer(EPortainerOperation.install);
                break;
            case EPortainerOperation.resetPassword:
                this.operationsPortainer(EPortainerOperation.stop);
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: portainerCmd.resetPassword.cmd, args: portainerCmd.resetPassword.args});
                this.operationsPortainer(EPortainerOperation.start);
                break;
            case EPortainerOperation.stop:
                this.operationsDocker(EDockerOperation.stopContainer, containerName);
                break;
            case EPortainerOperation.start:
                this.operationsDocker(EDockerOperation.startContainer, containerName);
                break;
            default:
                let portainerOpEnumValues: string = '';
                Generic.getEnumData(EPortainerOperation).forEach(val => {
                    if (portainerOpEnumValues.length == 0) {
                        portainerOpEnumValues = val;
                    } else {
                        portainerOpEnumValues += `|${val}`;
                    }
                });
                this.logger.warn(`Only accept arguments: ${portainerOpEnumValues}`);
                break;
        }
    }
    /*=============== END OF PORTAINER ==============*/

    /**============================================
     *!               OTHERS
     *=============================================**/
    private operationsDocker(type: EDockerOperation, name?: string) {
        name = name ? name : '';
        switch (type) {
            case EDockerOperation.stopContainer:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['stop', name]});
                break;
            case EDockerOperation.startContainer:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['start', name]});
                break;
            case EDockerOperation.removeContainer:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['rm', name]});
                break;
            case EDockerOperation.removeVolume:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['volume', 'rm', name]});
                break;
            case EDockerOperation.removeImage:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'ls']});
                const id = this.nodejsUtils.console.readKeyboard('Please insert ID to delete: ');
                if (id) {
                    this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'rmi', id]});
                }
                break;
            case EDockerOperation.removeAllUnused:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune -a']});
                break;
            case EDockerOperation.removeAll:
                this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune']});
                break;
            default:
                break;
        }
    }

    @annotateName
    private installDependencies() {
        let commands: ICommandInfo[] = [
            {
                cmd: this.nodejsUtils.console.setRootPermissionCmd('npm install -g htpasswd')
            }
        ];
        const platform = FilesSystem.getPlatform();
        switch (platform.data) {
            case EPlatformType.linux:
                commands.push({ cmd: 'sudo apt install curl' });
                commands.push({ cmd: 'curl -sSL https://get.docker.com | sh' });
                commands.push({ cmd: `sudo usermod -aG docker ${FilesSystem.readEnvVariable('USER')}` });
                commands.push({ cmd: 'sudo apt install docker-ce-cli containerd.io docker-compose docker-containerd' });
                for (const iterator of commands) {
                    const output = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: iterator.cmd});
                    if (output.hasError) {
                        break;
                    }
                }
                break;
            case EPlatformType.windows:
                this.logger.info('To install docker, visit: https://www.docker.com/products/docker-desktop');
                for (const iterator of commands) {
                    const output = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: iterator.cmd});
                    if (output.hasError) {
                        break;
                    }
                }
                break;
            default:
                throw platform.error;
        }
    }

    private informations() {
        this.logger.info(this.rootDir);
        this.logger.info(this.processDir);
        Generic.getLogger('Portainer').log(`
        - *Link install:* https://documentation.portainer.io/v2.0/deploy/ceinstalldocker
        `);
    }
    /*=============== END OF OTHERS ==============*/
}