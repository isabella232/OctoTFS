import * as tasks from 'vsts-task-lib/task';
import * as utils from "../Utils";
import {
    multiArgument,
    connectionArguments,
    includeArguments,
    flag,
    argumentEnquote,
    argumentIfSet
} from '../Utils/tool';

async function run() {
    try {
        const connection = utils.getDefaultOctopusConnectionDetailsOrThrow();
        const timeout = tasks.getInput("Timeout", false);
        const timeout2 = tasks.getInput("TimeoutMinutes", false);

        console.log(`Timeouts: timeout 1: "${timeout}" and timeout 2:"${timeout2}"`)
        const space = tasks.getInput("Space");
        const releaseNumber = tasks.getInput("ReleaseNumber", true);
        const environments = utils.getRequiredCsvInput("Environments");
        const showProgress = tasks.getBoolInput("ShowProgress");
        const deploymentForTenants = utils.getOptionalCsvInput("DeployForTenants");
        const deployForTenantTags = utils.getOptionalCsvInput("DeployForTenantTags");
        const additionalArguments = tasks.getInput("AdditionalArguments");
        const project = await utils.resolveProjectName(connection, tasks.getInput("Project", true))
            .then(x => x.value);

        const octo = await utils.getOrInstallOctoCommandRunner("deploy-release");

        const configure = [
            argumentIfSet(argumentEnquote, "space", space),
            argumentEnquote("project", project),
            argumentEnquote("releaseNumber", releaseNumber),
            connectionArguments(connection),
            multiArgument(argumentEnquote, "deployTo", environments),
            multiArgument(argumentEnquote, "tenant", deploymentForTenants),
            multiArgument(argumentEnquote, "tenanttag", deployForTenantTags),
            flag("progress", showProgress),
            includeArguments(additionalArguments)
        ];

        const code:Number = await octo.map(x => x.launchOcto(configure))
            .getOrElseL((x) => { throw new Error(x); });

        tasks.setResult(tasks.TaskResult.Succeeded, "Deploy succeeded with code " + code);
    }catch(err){
        tasks.error(err);
        tasks.setResult(tasks.TaskResult.Failed, "Failed to deploy release " + err.message);
    }
}

run();
