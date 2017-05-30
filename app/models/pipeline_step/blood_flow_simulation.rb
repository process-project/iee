# frozen_string_literal: true
module PipelineStep
  class BloodFlowSimulation
    def initialize(patient, user)
      validate_procedure_status!(patient)
      @computation = RimrockComputation.create(
        patient: patient,
        user: user,
        pipeline_step: 'virtual_model_ready',
        script: ScriptGenerator::BloodFlow.new(patient, user).call
      )
    end

    def run
      Rimrock::StartJob.perform_later @computation
      @computation
    end

    private_class_method

    def validate_procedure_status!(patient)
      statuses = Patient.procedure_statuses
      model_ready = statuses[patient.procedure_status] >= statuses['virtual_model_ready']
      raise('Virtual model must be ready to run Blood Flow Simulation') unless model_ready
    end
  end
end
