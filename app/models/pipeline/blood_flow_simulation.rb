# frozen_string_literal: true
module Pipeline
  class BloodFlowSimulation
    def self.run(patient, user)
      validate_procedure_status!(patient)
      computation = RimrockComputation.create(
        patient: patient,
        user: user,
        pipeline_step: 'virtual_model_ready',
        script: BloodFlowScriptGenerator.new(patient, user).script
      )
      Rimrock::StartJob.perform_later computation
      computation
    end

    private_class_method

    def self.validate_procedure_status!(patient)
      statuses = Patient.procedure_statuses
      model_ready = statuses[patient.procedure_status] >= statuses['virtual_model_ready']
      raise('Virtual model must be ready to run Blood Flow Simulation') unless model_ready
    end
  end
end
