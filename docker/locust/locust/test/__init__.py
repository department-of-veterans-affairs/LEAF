try:
    import resource

    # work around occasional "zmq.error.ZMQError: Too many open files"
    # this is done in main.py when running locust proper so we need to do it here as well
    resource.setrlimit(
        resource.RLIMIT_NOFILE,
        (
            10000,
            resource.RLIM_INFINITY,
        ),
    )
    changed_rlimit = True
except Exception:
    changed_rlimit = False

import os

# Clean environment from stuff you might have lying around
os.environ.pop("LOCUST_WEB_LOGIN", None)
# Ensure locust-cloud is not loaded during tests
os.environ.pop("PGHOST", None)
os.environ.pop("CHHOST", None)
