This guide assumes basic knowledge of the Linux environment and command-line. It assumes the is a terminal open in the directory with the files from the submitted archive.

# FMIDE 

If downloading the archived release, then once it is expanded, move to the **Example Walk Through**.

[![DOI](https://zenodo.org/badge/349156584.svg)](https://zenodo.org/badge/latestdoi/349156584)

Otherwise, the `fmide.sh` script downloads OSATE and adds to OSATE the BriefCASE tools. The script takes a single argument to indicate the install directory. **WARNING**: the script **deletes** and **recreates** the named directory so be sure it does not contain other useful items. The following command runs the script and installs the tools in an `fmide` directory that it creates in the same directory where the script is located.

```sh
$ ./fmide.sh fmide
```

The script does take a moment to install OSATE and BriefCASE as these must be downloaded from the named sites. The scripts names the install location when completed (should match the one specified on the command line). That install location is referred to as `FMIDE_DIR` for the remainder of this document.

The BriefCASE tool suite must be updated before it is possible to move onto the example walkthrough. In a terminal, launch the `fmide` tool with

```sh
$ cd FMIDE_DIR 
$ ./fmide &
```

After a moment, the OSATE splash screen will appear followed by a dialogue for the workspace to use. Choose the default workspace or name a preferred location. OSATE is integrated into the Eclipse IDE, so for those who have used Eclipse, interacting with OSATE will be very intuitive.

Once the main OSATE window is open, click on the `Help` menu and select `Install New Software`. The `Install` dialogue should appear. In that dialogue, click the `Add...` button. The `Add Repository` should appear. In that dialogue, click the `Archive` button. 

There should be a `com.collins.trustedsystems.briefcase.repository-0.5.2-SNAPSHOT.zip` packaged in the submitted archive for the artifact evaluation. Navigate to directory with that file, select the file, and then choose `Open`. That returns to the `Add Repository` dialogue. Click `Add` to then return to the `Install` dialogue. `BriefCase (by Collins Aerospace)` and `BriefCASE Source Code` should show as two possible choices to add. Select `BriefCASE (by Collins Aerospace)` and click `Next`. 

After sometime, a new dialogue appears with `Install Details`. It is saying that `BriefCASE` is already installed and indicating that an update will be performed. Click `Next` to proceed with the update. The `Review License` dialogue appears. Select the `I accept the terms of the license agreement` and click `Finish`. A `Security Warning` dialogue should appear. Click `Install anyway`. A `Software Updates` dialogue then appears. Click `Restart Now`.

# Example Walk Through

The example in the paper to describe the specification, verification, and synthesis of the high assurance components is hosted on [Github](http://github.com) in a public repository named [verified-mon-flt-synthesis](https://github.com/ericmercer/verified-mon-flt-synthesis). The repository contains the source for the paper, presentations, and everything here related to the artifact evaluation. The repository is easily cloned with `git clone https://github.com/ericmercer/verified-mon-flt-synthesis`. Once the example files are cloned, start up `fmide`.

The main OSATE window should appear at this point. Click the `File` menu and select `Import ...`. In the `Import` dialogue, expand `General` and select `Existing Projects into Workspace`. This section brings a new `Import` dialogue. The radio button for `Select root direcory` should be indicated. Click the `Browse` button next to it. Navigate to the location where the repository is cloned and click `Open`. The `Projects` box should show **uxaslite**, and it should already be selected. Click `Finish` to complete the import.

The **AADL Navigator** pane should now show `uxaslite`. Expand the folder and double-click `SW.aadl` to open the file in the editor. This file defines the example models discussed in the paper.  The unhardened model is `SW.Impl` while the hardened model is `SW.cyber_Impl` These are both located near the bottom of the file. The block diagrams for both are in the `diagrams` folder that can be accessed in the **AADL Navigator** pane. Double-click a diagram to open it.

## Running AGREE

Open the `SW.aadl` file and navigate to the `SW.Impl` process implementation. Click on the actual `SW.Impl` text so that the cursor is located somewhere in that text. Right-click to get the context menu, select `AGREE` and then select `Verify Single Layer`. An `AGREE Results` window that is similar to the figure in the paper should appear showing the AGREE analysis results Repeat this process for the `SW.cyber_Impl` to verify that the hardened version passes verification.

## Running SPLAT Synthesis
 
Open the `SW.aadl` file and click anywhere in the file. Right click to get the context menu, select `BriefCASE`. Then select `Cyber Resiliency`. Then select `Synthesis Tools`. And finally select `Run SPLAT`. The console reports where the synthesized files are located and reports that `SPLAT completed successfully`.

Each synthesized component is placed in its own directory. The file with the `.cml` extension in the synthesized CakeML. For the filter example here, the file is named `SW_CASE_Filter_Thr.cml`. The other files are related to `seL4` integration and outside the scope of the paper and artifact evaluation.

## Model Transforms

BriefCASE is able to transform the model to automatically insert cyber-resilient filters and monitors. To add a **filter**, open the `SW.aadl` file and navigate to the `SW.Impl` process implementation. Click on connection `c05` so the cursor is anywhere in that label. The selected connection indicates *where* in the model the filter is to be added. Right-click to get the pop-up menu and select `Cyber Resiliency`, `Model Transformations`, and then `Add Filter...`. Complete the various field as desired. It is okay to leave the `Filter Policy` unspecified and define it later with an `AGREE` contract later as is done in the example system; otherwise, the policy can be specified with a regular expression. Click `OK`. After a moment, the `SW.aadl` file will reload with the added component in `SW.Impl`, and the component is also added to the file with the indicated name.

The process to add a monitor is the same as that to add a filter. Select the `Add Monitor...` option instead. The dialogue is more complicated for the monitor since it is able to reason over several inputs. Complete the dialogue and click `OK`. Again, after a brief moment, the `SW.aadl` file is refreshed showing the added component and connections. As before, the actual monitor policy then needs to be specified with an `AGREE` contract.