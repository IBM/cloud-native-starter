package com.ibm.webapi.business;

import java.util.Collection;
import java.util.List;
import java.util.concurrent.*;
import java.util.function.Supplier;

public class TestManagedExecutor implements org.eclipse.microprofile.context.ManagedExecutor {

    private final ExecutorService executorService = Executors.newFixedThreadPool(4);

    @Override
    public <U> CompletableFuture<U> completedFuture(U u) {
        return null;
    }

    @Override
    public <U> CompletionStage<U> completedStage(U u) {
        return null;
    }

    @Override
    public <U> CompletableFuture<U> failedFuture(Throwable throwable) {
        return null;
    }

    @Override
    public <U> CompletionStage<U> failedStage(Throwable throwable) {
        return null;
    }

    @Override
    public <U> CompletableFuture<U> newIncompleteFuture() {
        return null;
    }

    @Override
    public CompletableFuture<Void> runAsync(Runnable runnable) {
        return null;
    }

    @Override
    public <U> CompletableFuture<U> supplyAsync(Supplier<U> supplier) {
        return CompletableFuture.supplyAsync(supplier, executorService);
    }

    @Override
    public void shutdown() {

    }

    @Override
    public List<Runnable> shutdownNow() {
        return null;
    }

    @Override
    public boolean isShutdown() {
        return false;
    }

    @Override
    public boolean isTerminated() {
        return false;
    }

    @Override
    public boolean awaitTermination(long timeout, TimeUnit unit) throws InterruptedException {
        return false;
    }

    @Override
    public <T> Future<T> submit(Callable<T> task) {
        return null;
    }

    @Override
    public <T> Future<T> submit(Runnable task, T result) {
        return null;
    }

    @Override
    public Future<?> submit(Runnable task) {
        return null;
    }

    @Override
    public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks) throws InterruptedException {
        return executorService.invokeAll(tasks);
    }

    @Override
    public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks, long timeout, TimeUnit unit) throws InterruptedException {
        return executorService.invokeAll(tasks);
    }

    @Override
    public <T> T invokeAny(Collection<? extends Callable<T>> tasks) throws InterruptedException, ExecutionException {
        return null;
    }

    @Override
    public <T> T invokeAny(Collection<? extends Callable<T>> tasks, long timeout, TimeUnit unit) throws InterruptedException, ExecutionException, TimeoutException {
        return null;
    }

    @Override
    public void execute(Runnable command) {

    }
}
