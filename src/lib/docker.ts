import { Response, ResponseBuilder } from './../../utils/nodejs-utils/src/lib/response';
import { IResponse } from './../../utils/nodejs-utils/src/interface/response';
import { Generic } from './../../utils/nodejs-utils/src/lib/generic';
import { ICommandInfo } from './../../utils/nodejs-utils/src/interface/comand-info';
import { App } from "../app";
import { EPlatformType } from "../../utils/nodejs-utils/src/enum/platform-type-enum";
import { EDockerOperation } from '../enum/docker-operation';
import { annotateName } from '../../utils/nodejs-utils/src/lib/decorators';
import { FilesSystem } from '../../utils/nodejs-utils/src/lib/files-system';

export class Docker extends App {
    private readonly containerNamePortainer = 'portainer';
    constructor() {
        super();
    }
    
    protected menu() {
        this.nodeMenu
            // Portainer
            .addDelimiter('-', this.delimiterWithTitle, 'Portainer')
            .addItem('Install', this.installPortainer, this, [{'name': this.getOptionalArg('password'), 'type': 'string'}])
            .addItem('Update', (password: string) => {
                this.uninstallPortainer();
                this.installPortainer(password);
            }, this, [{'name': this.getOptionalArg('password'), 'type': 'string'}])
            .addItem('Uninstall', this.uninstallPortainer, this)
            .addItem('Reset Password', this.resetPasswordPortainer, this)
            .addItem('Stop', () => { this.startStopPortainer(true); }, this)
            .addItem('Start', this.startStopPortainer, this)

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
            .addDelimiter('-', this.delimiter)
            .addItem('Informations', this.informations, this)
            .addItem('Install Dependency', this.installDependencies, this);
    }

    /**============================================
     *!               PORTAINER
     *=============================================**/
    private createVolumePortainer(): IResponse<number|null> {
        return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['volume', 'create', 'portainer_data']});
    }

    @annotateName
    private installPortainer(password: string = ''): IResponse<number|null> {
        const hashPassword = Generic.hashPassword('admin', password);
        if (hashPassword.hasError) {
            this.logger.error(hashPassword.error);
        } else {
            password = `--admin-password="${hashPassword.data}"`;
        }
        let createVolume = this.createVolumePortainer();
        if (createVolume.hasError) {
            return createVolume;
        }
        this.logger.warn('If password not working, please reset password!!!');
        return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: [
            'run -d -p 8000:8000 -p 9000:9000',
            '--name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce',
            password
        ]});
    }

    @annotateName
    private uninstallPortainer(): IResponse<number|null> {
        let response: IResponse<number|null> = new Response();
        [EDockerOperation.stopContainer, EDockerOperation.removeContainer, EDockerOperation.removeImage].forEach(op => {
            response = this.operationsDocker(op, this.containerNamePortainer);
            if (response.hasError) {
                return response;
            }
        });
        return response;
    }

    @annotateName
    private resetPasswordPortainer(): IResponse<number|null> {
        let response = this.startStopPortainer(true);
        if (response.hasError){
            return response;
        }
        response = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['run --rm -v portainer_data:/data portainer/helper-reset-password']});
        if (!response.hasError) {
            return this.startStopPortainer();
        }
        return response;
    }

    @annotateName
    private startStopPortainer(isStop: boolean = false): IResponse<number|null> {
        if (isStop) {
            return this.operationsDocker(EDockerOperation.stopContainer, this.containerNamePortainer);
        }
        return this.operationsDocker(EDockerOperation.startContainer, this.containerNamePortainer);
    }
    /*=============== END OF PORTAINER ==============*/

    /**============================================
     *!               OTHERS
     *=============================================**/
    private operationsDocker(type: EDockerOperation, name?: string): IResponse<number|null> {
        name = name ? name : '';
        switch (type) {
            case EDockerOperation.stopContainer:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['stop', name]});
            case EDockerOperation.startContainer:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['start', name]});
            case EDockerOperation.removeContainer:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['rm', name]});
            case EDockerOperation.removeVolume:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['volume', 'rm', name]});
            case EDockerOperation.removeImage:
                let imageLs = this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'ls']});
                if (!imageLs.hasError) {
                    const id = this.nodejsUtils.console.readKeyboard('Please insert ID to delete: ');
                    if (id) {
                        return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'rmi', id]});
                    }
                }
                return imageLs;
            case EDockerOperation.removeAllUnused:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune -a']});
            case EDockerOperation.removeAll:
                return this.nodejsUtils.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune']});
            default:
                let dockerOpEnumValues: string = '';
                Generic.getEnumData(EDockerOperation).forEach(val => {
                    if (dockerOpEnumValues.length == 0) {
                        dockerOpEnumValues = val;
                    } else {
                        dockerOpEnumValues += `|${val}`;
                    }
                });
                return new ResponseBuilder<number|null>()
                            .withData(111)
                            .withError(new Error(dockerOpEnumValues))
                            .build();
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
                this.logger.info('*Docker - Link install:* https://www.docker.com/products/docker-desktop');
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
        Generic.getLogger('Portainer').log(`
        - *Link install:* https://documentation.portainer.io/v2.0/deploy/ceinstalldocker
        `);
    }
    /*=============== END OF OTHERS ==============*/
}