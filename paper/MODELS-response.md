# Notes

(sentence in the introduction) CASE was scoped to address the more common cyber-vulnerabilities that programmers introduce such as overflow and lack of input validation, supply-chain issues, identity verification and not things such as side-channel and denial of service vulnerabilities.

Not inventing any new type of filter are monitor in terms of capability. Here we are giving a way to synthesize such things from a formal specification. Provide a means from a specification to code and a way to show it is correct. 

Doing it in a way that enable rapid evaluation and early synthesis targeting VM or Linux for early feedback before the full system is fielded for test. Early validation is key here.

Case-study motivation: showcase the tool chain in an industrial scale problem to see if the technology works. Some anecdotal information about impact on engineers. In the end though, a manual process now has tool support for early validation. So it went from nothing to something and provides early information about cyber-vulnerabilities and effectiveness of intervention. Take UXAS message format on board, complex real-world message format, and it works in the tool. The tool handles these complex message types. Existing real world example with a lot of complexity. Validates the utility, capability, of the tool. <== Real motivation.

For the case study, shift the focus to be more specific to the filter and monitor, and more passing on the other things that are part of BriefCASE. Weave in the above discussion on the tool.

## Summary of Changes

  * Add sentence about limitations
  * Rework case-study to focus on filter and monitor
  * Add discussion about what case-study needs to accomplish
  * Update figures on slat synthesized code.
   
# Response to Reviewer Questions

**Limit:** 500 words

Thank for your the thoughtful reviews.

Regarding 1) The before and after tool chains have been compared showing that there is great value in the synthesized CakeML code from the AGREE specification. Before BriefCASE, the process was fully manual requiring domain expertise in AADL, AGREE, and CakeML. It additionally required manual inspection and code review of the CakeML to argue the correctness of the implementation. The new approach in the paper is near push-button to synthesize from the AGREE specification the CakeML implementation. That implementation is proved correct automatically thus removing any need for code review or manual argument of correctness in the implementation.

Regarding 2) See 1.

Regarding 3) The developers must write and debug the policies used in the model transformations. Writing these policies is a non-trivial task depending on the complexity of the data or the behavior that must be detected. The developer must also write the contracts around the high-assurance components to prove the policies work, and these must be sufficient to prove the system is cyber-hardened against the indicated attacks. It is true that AGREE proves the contracts hold when chained together, but if the contract does not actually capture the intent of the system engineer, then the analysis has no meaning.

Regarding 4) The approach is well-suited to detecting attacks that fuzz data or impersonate communication. More sophisticated attacks that require a temporal sequence of events are more difficult to express in the specification language and soon become very complex to reason about. The same is true about attacks that manipulate complex data-structures such as trees and lists. An example is a monitor that detects non-regular movement of aircraft in real-time. The messages formats and complex computations yield a complicated specification that is hard to manually reason about. The synthesis is guaranteed correct, but it is hard to know if the specification is correct. So this work solves the problem of creating a correct implementation from a specification where correct means it exactly preserves the meaning of the specification, but whether or not the specification captures the desired intent is an open problem. 

Regarding 5) Yes. The tests are derived with Black-box input partitioning applied to the specifications for the high-assurance components and in consultation with the system engineers. Effectively these are system level tests with expected unit level outcomes to exercise each filter and monitor in the system so that each accepts, blocks, or alarms as appropriate.

# Reviewers Most Important Questions

Please focus your response to address the following questions and concerns raised by the reviewers of the paper

  1) Have you performed any comparison of the proposed approach with the simple use of the existing tool chain (without the model transformations)?
  2) What types of effort were reduced by the automated model transformations? Do you have any evidence/feedback on the extent to which the filter/monitor model transformations and code generation helped developers?
  3) What types of manual effort remain, and can you say anything about the amounts of effort that need to be expended by the developers?
  4) What can you say about limitations of the approach (types of attacks, types of model transformations)?
  5) Can you provide additional details on the four sets of tests conducted to measure the effectiveness of the process?

# Summary of Reviews

There needs to be a discussion of the limitations of the approach including what types of attacks can and cannot by mitigated as well as the guarantees that can or cannot be made before and after the transformations. 

The case study needs to be revised to make clear the research questions it is trying to answer and how it will answer those questions. It also needs some discussion of life before and after the tool vis a vis the system engineers.

# Review 1

**SCORE:** 1 (weak accept)

The paper addresses an important and timely topic. Cyber resiliency in any cyber-physical system is an essential requirement, including the systems used in avionics. It is a well-known fact that there is a clear need for proper tools in cyber assured systems engineering in the industry.

The paper presents two analysis tools to add new design, analysis, and code generation capabilities for building cyber-resilient systems. The paper discusses a Model-Based Systems Engineering environment called BriefCASE, an extension to an Open Source AADL Tool Environment. The paper outlines the needs for combining the mitigation strategies for the potential vulnerabilities during the design, analysis, and early development phases to avoid discovering issues in later stages resulting in expensive and time-consuming resolutions. The paper evaluates the approach through a simple case study and verifies its effectiveness.


The paper is well-written and the problem statements described in the paper have certain practical and industrial importance, and the authors have presented an innovative solution that is essential to the software engineering domain. The paper clearly explains the approach, techniques, and methodologies employed. As suggested by the authors, the example in section II is notably simple compared to the complex case study, which may have further complicated vulnerabilities listed in the paper. I find that the approach used in this paper helps the reader to understand the context first in simpler terms and gradually grasp the complexity of the circumstances and the importance of the presented solution.

However, the paper needs to outline additional details on the four sets of tests conducted to measure the effectiveness of the process. The paper briefly outlined the overall scenario and provided the output messages in Fig. 13. But it would be helpful if the readers can understand the input (sample message) sent to the system and how the proposed BriefCASE tool helped find and mitigate the selected vulnerabilities. If explaining all four tests with details may extend  the page limit, authors can pick one test and explain it further. For example, in Test b, Malformed Line Search Task message, the paper can include a sample of such malicious waypoint and how wellformedness filter prevented the message from reaching the UxAS, significantly how BriefCASE tool considered to implement such filter in the first place. This way, I believe, the paper can provide more proof of the proposed model's effectiveness on the hardened system. 

Another shortcoming is that the related work does not include any recent work published after 2018. The paper also lacks the discussion on the limitation of the approach which is a requirement for this track. 

Minor comment: There are some grammar mistakes and typos that paper needs to address.

# Review 2

**SCORE:** -1 (weak reject)

This paper aims to provide a tool-chain supporting  architecture evolution in response to identified vulnerabilities and cyber-security requirements. In particular, this paper proposes automated model transformations for applying two architectural tactics (adding filter and monitor) to an AADL-based architecture model and generating those AGREE specifications. In addition, this paper proposes automated synthesis of CakeML program for the filer and monitor. The authors conducted case study with a UAV surveillance system and demonstrated how an architecture was evolved by using the model transformation to support seven cyber-security requirements.

This paper is well written and easy to follow, except for the case study. The topic addressed is interesting and the tool-chain with the model transformation looks well designed. The whole solution well covers from specification to implementation to provide guarantees.

The presentation of the case study section needs further improvements. 
  * Section 5 should be structured.
  * Research question(s) addressed by the case study should be clarified
  * AADL models in Fig.9 and Fig.12 are too small

In particular, the significance of the proposed approach needs to be clarified. It would be better to discuss to what extend the filter/monitor model transformations and code generation helped developers by comparing the approach with the simple use of the existing tool-chain (without the model transformation). What types of efforts were reduced by the automated model transformation? What are the efforts that developers still have to do manually? Based on this, it is necessary to discuss the effectiveness and its significance of the proposed approach.

# Review 3

**SCORE:** 1 (weak accept)

This paper describes BriefCASE, which extends the Open Source AADL Tool Environment by adding automated model transformations that introduce high-assurance cyber-resiliency components into a system that prevent malicious input and detect attacks. The approach is demonstrated using a UAV system as an example.

Overall, the paper is very well-written and presents a compelling application of model-driven techniques to a real-world application. The analysis of the approach is complete in that it considers an example whose size and scale meets the complexity of a real-world design. The approach presented by the authors could certainly be used in other application domains as well.

**Major criticisms:**

A discussion on what guarantees must be imposed on the model transformations would be useful. Without verifying the correctness of the transformations, can prevention of certain attacks be guaranteed? The authors should consider commenting on this.

The paper lacks a discussion of limitations of the approach. For example, are there certain types of attacks that cannot be prevented? Is there an attack vector that could still be exploited? The authors should also discuss the possibility of a valid message being interpreted as a malicious message and what impact that may have.

**Minor criticisms:**

For the reference for CakeML, it would be good to include a date on which the site was accessed.