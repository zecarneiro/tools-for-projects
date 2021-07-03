import { IResponse } from './../../sub-projects/utils/interface/response';
import { EPlatformType } from '../../sub-projects/utils/enum/platform-type';
import { ICommandInfo } from '../../sub-projects/utils/interface/comand-info';
import { ResponseBuilder } from '../../sub-projects/utils/nodejs/builder/response';
import { annotateName } from '../../sub-projects/utils/nodejs/decorators';
import { FilesSystem } from '../../sub-projects/utils/nodejs/files-system';
import { Generic } from '../../sub-projects/utils/nodejs/generic';
import { App } from '../app';

export class Docker extends App {
    private readonly containerNamePortainer = 'portainer';
    constructor() {
        super(true);
    }
    
    protected menu() {
        this.nodeMenu
            // Portainer
            .addDelimiter('-', this.delimiterWithTitle, 'Portainer')
            .addItem('Install', this.installPortainer, this, [{name: this.getOptionalArg('password'), type: 'string'}])
            .addItem('Update', (password: string) => {
                this.uninstallPortainer();
                this.installPortainer(password);
            }, this, [{name: this.getOptionalArg('password'), type: 'string'}])
            .addItem('Uninstall', this.uninstallPortainer, this)
            .addItem('Reset Password', this.resetPasswordPortainer, this)
            .addItem('Stop', () => { this.startStopPortainer(true); }, this)
            .addItem('Start', this.startStopPortainer, this)

            // Docker Operations
            .addDelimiter('-', this.delimiterWithTitle, 'Operations')
            .addItem('List Images', () => this.listImages(false))
            .addItem('Stop Container', (name: string) => { this.stopContainer(name); }, this, [{name: 'name', type: 'string'}])
            .addItem('Start Container', (name: string) => { this.startContainer(name); }, this, [{name: 'name', type: 'string'}])
            .addItem('Remove Container', (name: string) => { this.removeContainer(name); }, this, [{name: 'name', type: 'string'}])
            .addItem('Clean Exited Containers', this.cleanExitedContainers, this)
            .addItem('Remove Volume', (name: string) => { this.removeVolume(name); }, this, [{name: 'name', type: 'string'}])
            .addItem('Remove Image', this.removeImage, this)
            .addItem('Clean Images', this.cleanImages, this)
            .addItem('Remove All Unused', () => { this.removeAllUnused(); }, this)
            .addItem('Remove All', () => { this.removeAll(); }, this)

            // Others
            .addDelimiter('-', this.delimiter)
            .addItem('Informations', this.informations, this)
            .addItem('Install Dependency', this.installDependencies, this);
    }

    /**============================================
     *!               PORTAINER
     *=============================================**/
    @annotateName
    private createVolumePortainer() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['volume', 'create', 'portainer_data']}).error);
    }
    @annotateName
    private installPortainer(password: string = '') {
        const hashPassword = Generic.hashPassword('admin', password);
        if (hashPassword.hasError) {
            this.logger.error(hashPassword.error);
        } else {
            password = `--admin-password="${hashPassword.data}"`;
        }
        this.createVolumePortainer();
        this.logger.warn('If password not working, please reset password!!!');
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: [
            'run -d -p 8000:8000 -p 9000:9000',
            '--name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce',
            password
        ]}).error);
    }
    @annotateName
    private uninstallPortainer() {
        this.stopContainer(this.containerNamePortainer);
        this.removeContainer(this.containerNamePortainer);
        this.removeImage();
    }
    @annotateName
    private resetPasswordPortainer() {
        this.startStopPortainer(true);
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['run --rm -v portainer_data:/data portainer/helper-reset-password']}).error);
        this.startStopPortainer();
    }
    @annotateName
    private startStopPortainer(isStop: boolean = false) {
        if (isStop) {
            this.stopContainer(this.containerNamePortainer)
        } else {
            this.startContainer(this.containerNamePortainer);
        }
    }
    /*=============== END OF PORTAINER ==============*/

    /**============================================
     *!               OTHERS
     *=============================================**/
    @annotateName
    private listImages(getId: boolean): IResponse<string> {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'ls']}).error);
        let id: string = '';
        if (getId) {
            id = this.console.readKeyboard('Please insert ID of image: ');
        }
        return new ResponseBuilder<string>().withData(id).build();
    }
    @annotateName
    private stopContainer(name: string) {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['stop', name]}).error);
    }
    @annotateName
    private startContainer(name: string) {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['start', name]}).error);
    }
    @annotateName
    private removeContainer(name: string) {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['rm', name]}).error);
    }
    @annotateName
    private cleanExitedContainers() {
        const listIds = this.console.execSync({cmd: 'docker', args: ['ps', '--filter=status=exited', '--filter=status=created', '-q']});
        this.processError(listIds.error);
        const ids: string[] = listIds.stdout ? listIds.stdout.split('\n') : [];
        ids.forEach(id => this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['rm', id]}).error));
    }
    @annotateName
    private removeVolume(name: string) {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['volume', 'rm', name]}).error);
    }
    @annotateName
    private removeImage() {
        let imageLs = this.listImages(true);
        if (imageLs.data.length > 0) {
            this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['image', 'rmi', imageLs.data]}).error);
        } else {
            this.processError(new Error('Invalid image ID'));
        }
    }
    @annotateName
    private cleanImages() {
        const listIds = this.console.execSync({cmd: 'docker', args: ['images', '-a', '--filter=dangling=true', '-q']});
        this.processError(listIds.error);
        const ids: string[] = listIds.stdout ? listIds.stdout.split('\n') : [];
        ids.forEach(id => this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['rmi', id]}).error));
    }
    @annotateName
    private removeAllUnused() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune -a']}).error);
    }
    @annotateName
    private removeAll() {
        this.processError(this.console.execSyncWhitoutOutput({cmd: 'docker', args: ['system prune']}).error);
    }

    @annotateName
    private installDependencies() {
        let commands: ICommandInfo[] = [
            {
                cmd: this.console.setRootPermissionCmd('npm install -g htpasswd')
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
                    this.processError(this.console.execSyncWhitoutOutput({cmd: iterator.cmd}).error);
                }
                break;
            case EPlatformType.windows:
                this.logger.info('*Docker - Link install:* https://www.docker.com/products/docker-desktop');
                for (const iterator of commands) {
                    this.processError(this.console.execSyncWhitoutOutput({cmd: iterator.cmd}).error);
                }
                break;
            default:
                this.processError(platform.error);
        }
    }

    @annotateName
    private informations() {
        this.logger.log('- Portainer\n\t*Link install:* https://documentation.portainer.io/v2.0/deploy/ceinstalldocker');
    }
    /*=============== END OF OTHERS ==============*/
}