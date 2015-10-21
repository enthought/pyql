# -*- coding: utf-8 -*-
"""
Simulation of Double Exponential Joint Diffusion model
"""

import numpy as np


def jump_times(beta, nb_scenarios, horizon):
    """
    Simulate jump times till horizon T
    returns 2d array of jump times, one per scenarios
    """

    indx = range(nb_scenarios)
    out = np.zeros((nb_scenarios, 1))
    all_done = False
    k = 1
    while not all_done:
        tmp = horizon * np.ones(nb_scenarios)
        next_jump = out[indx, k - 1] + np.random.exponential(beta, len(indx))
        next_jump = [min(x, horizon) for x in next_jump]
        tmp[indx] = next_jump
        tmp.shape = (nb_scenarios, 1)
        out = np.hstack((out, tmp))
        k += 1
        indx = np.where(tmp < horizon)[0]
        all_done = (len(indx) == 0)

    return out


def jump_samples(eta_1, eta_2, prob_up_jump, jump_times, time_steps):

    """
    jump samples for each time step
    """

    nb_scenarios = jump_times.shape[0]
    horizon = time_steps[-1]

    # time intervals between jumps. Null after last jump for path
    dt = np.diff(jump_times, 1)

    # sample jump direction from uniform density
    dice = np.random.rand(*dt.shape)
    upIndx = np.where((dice <= prob_up_jump) & (dt > 0))
    dnIndx = np.where((dice > prob_up_jump) & (dt > 0))

    print upIndx
    # sample jump magnitude from exponential density
    jump_tmp = np.zeros(dt.shape)
    jump_tmp[upIndx] = np.random.exponential(1. / eta_1, len(upIndx[0]))
    jump_tmp[dnIndx] = -np.random.exponential(1. / eta_2, len(dnIndx[0]))

    jumps = np.zeros((nb_scenarios, len(time_steps)))

    for i in range(nb_scenarios):
        jjt = jump_times[i, 1:]
        indx = np.where(jjt < horizon)[0]
        if len(indx) > 0:
            for k in range(len(indx)):
                kndx = np.where(jjt[indx[k]] <= time_steps)[0]
                # there can be more than one jump in one interval
                print i, kndx[0], k, indx[k]
                jumps[i, kndx[0]] += jump_tmp[i, indx[k]]

    return jumps

if __name__ == '__main__':

    eta_1 = .1
    eta_2 = .2
    prob_up_jump = .4
    horizon = 3
    beta = 1
    nb_paths = 5

    time_steps = np.arange(0, horizon, .5)

    jt = jump_times(beta, nb_paths, horizon)
    js = jump_samples(eta_1, eta_2, prob_up_jump,
                 jt, time_steps)
    print jt
    print js
