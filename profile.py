"""This profile is used to instantiate a build VM in OCT. DO NOT USE 

Instructions:
Wait for the profile instance to start, and then log in to the VM via the
ssh port specified below.  (Note that in this case, you will need to access
the VM through a high port on the physical host, since we have not requested
a public IP address for the VM itself.)
"""

import geni.portal as portal
import geni.rspec.pg as pg

# Create a Request object to start building the RSpec.
pc = portal.Context()
request = pc.makeRequestRSpec()

numRAM = [32, 64, 96]
numCPU = [4, 8, 12]

vitisVersion = [('2021.2'), ('2022.1')]

xrtVersion = [('2021.1'), ('2022.1'), ('Do not install tools')]  

pc.defineParameter("numRAM",  "RAM size (GB)",
                   portal.ParameterType.INTEGER, numRAM[0], numRAM,
                   longDescription="RAM size")

pc.defineParameter("numCPU",  "No: of VCPUs",
                   portal.ParameterType.INTEGER, numCPU[0], numCPU,
                   longDescription="No: of VCPUs")

pc.defineParameter("vitisVersion", "Vitis Version",
                   portal.ParameterType.STRING,
                   vitisVersion[0], vitisVersion,
                   longDescription="Select the Vitis version.")   

pc.defineParameter("xrtVersion", "XRT Version",
                   portal.ParameterType.STRING,
                   xrtVersion[0], xrtVersion,
                   longDescription="Select a tool version.")   

pc.defineParameter("enableRemoteDesktop", "Remote Desktop Access",
                   portal.ParameterType.BOOLEAN, False,
                   advanced=False,
                   longDescription="Enable remote desktop access by installing GNOME desktop and VNC server.")

params = pc.bindParameters() 
 
# Create a XenVM
#node = request.XenVM("build-vm")
name = "node" + str(0)
node = request.RawPC(name)
#node.xen_ptype = "build-vm"
node.hardware_type = "fpga-alveo"
node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD"
# node.exclusive = False

# Request a specific number of VCPUs.
#node.cores = params.numCPU

# Request a specific amount of memory (in MB).
#node.ram = 1024*params.numRAM

# Set Storage
#node.disk = 40

if params.xrtVersion != "Do not install tools":
  node.addService(pg.Execute(shell="bash", command="sudo /local/repository/post-boot.sh " + str(params.enableRemoteDesktop) + " " + params.xrtVersion + " " + params.vitisVersion + " >> /local/repository/output_log.txt"))  
pass 
   

# Print the RSpec to the enclosing page.
portal.context.printRequestRSpec()
