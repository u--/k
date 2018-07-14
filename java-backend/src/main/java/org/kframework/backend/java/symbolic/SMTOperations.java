// Copyright (c) 2015-2018 K Team. All Rights Reserved.
package org.kframework.backend.java.symbolic;

import org.kframework.main.GlobalOptions;
import org.kframework.backend.java.kil.Definition;
import org.kframework.backend.java.kil.Variable;
import org.kframework.backend.java.util.Z3Wrapper;
import org.kframework.utils.errorsystem.KExceptionManager;
import org.kframework.utils.options.SMTOptions;
import org.kframework.utils.options.SMTSolver;

import java.util.Set;

import com.google.inject.Provider;

public class SMTOperations {

    private final SMTOptions        smtOptions;
    private final Z3Wrapper         z3;
    private final GlobalOptions     global;
    private final KExceptionManager kem;

    public SMTOperations(
            Provider<Definition> definitionProvider,
            SMTOptions smtOptions,
            Z3Wrapper z3,
            KExceptionManager kem,
            GlobalOptions global) {
        this.smtOptions = smtOptions;
        this.z3         = z3;
        this.kem        = kem;
        this.global     = global;
    }

    public boolean checkUnsat(ConjunctiveFormula constraint) {
        if (smtOptions.smt != SMTSolver.Z3) {
            return false;
        }

        if (constraint.isSubstitution()) {
            return false;
        }

        boolean result = false;
        try {
            CharSequence query = KILtoSMTLib.translateConstraint(constraint);
            if (global.debugFull) {
                System.err.format("\nAttempting to check unsat for:\n================= \n\t%s\n" +
                        "query: \n\t%s\n", constraint, query);
            }
            result = z3.isUnsat(query, smtOptions.z3CnstrTimeout);
            if (result && RuleAuditing.isAuditBegun()) {
                System.err.format("SMT query returned unsat: %s\n", query);
            }
        } catch (UnsupportedOperationException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Checks if {@code left => right}, or {@code left /\ !right} is unsat.
     */
    public boolean impliesSMT(
            ConjunctiveFormula left,
            ConjunctiveFormula right,
            Set<Variable> rightOnlyVariables) {
        if (smtOptions.smt == SMTSolver.Z3) {
            try {
                //From this point on, will be converted to toString() anyway.
                CharSequence query = KILtoSMTLib.translateImplication(left, right, rightOnlyVariables).toString();
                if (global.debug) {
                    System.err.format("\nz3 query: %s\n", query);
                }
                return z3.isUnsat(query, smtOptions.z3ImplTimeout);
            } catch (UnsupportedOperationException | SMTTranslationFailure e) {
                if (!smtOptions.ignoreMissingSMTLibWarning) {
                    kem.registerCriticalWarning(e.getMessage(), e);
                }
                if (global.debug) {
                    System.err.println(e.getMessage() + "\n");
                }
            }
        }
        return false;
    }
}
